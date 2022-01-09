# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::RSpec::Runner do
  subject { described_class }

  let(:map) { instance_double('Crystalball::MapStorage::YAMLStorage') }

  before do
    described_class.reset!
    allow(Crystalball::MapStorage::YAMLStorage).to receive(:load).and_return(map)
    allow(RSpec::Core::ExampleGroup).to receive(:run)
  end

  describe '.prepare' do
    let(:expected_config) { {'execution_map_path' => 'map.yml', 'map_expiration_period' => 0, 'prediction_builder_class_name' => 'Crystalball::RSpec::PredictionBuilder'} }
    let(:config_content) { expected_config.to_yaml }

    before do
      allow(Pathname).to receive(:new).and_call_original
      allow_any_instance_of(Crystalball::RSpec::PredictionBuilder).to receive(:expired_map?).and_return(false)
      allow_any_instance_of(described_class).to receive(:setup)
    end

    context 'with CRYSTALBALL_CONFIG env variable set' do
      let(:expected_config) { YAML.safe_load(Pathname('spec/fixtures/crystalball.yml').read, permitted_classes: [Symbol]) }

      around do |example|
        ENV['CRYSTALBALL_CONFIG'] = 'spec/fixtures/crystalball.yml'
        example.call
        ENV.delete('CRYSTALBALL_CONFIG')
      end

      specify do
        subject.prepare
        expect(subject.prediction_builder.config.to_h).to include('execution_map_path' => Pathname(expected_config['execution_map_path']))
      end
    end

    context 'if crystalball.yml is present' do
      let(:config_file) { double(read: config_content, exist?: true) }
      before do
        allow(Pathname).to receive(:new).with('crystalball.yml').and_return(config_file)
      end

      specify do
        subject.prepare
        expect(subject.prediction_builder.config.to_h)
          .to include(
            'execution_map_path' => Pathname(expected_config['execution_map_path']),
            'map_expiration_period' => 0
          )
      end
    end

    context 'if config/crystalball.yml is present' do
      let(:config_file) { double(read: config_content, exist?: true) }
      before do
        allow(Pathname).to receive(:new).with('crystalball.yml').and_return(double(exist?: false))
        allow(Pathname).to receive(:new).with('config/crystalball.yml').and_return(config_file)
      end

      specify do
        subject.prepare
        expect(subject.prediction_builder.config.to_h)
          .to include(
            'execution_map_path' => Pathname(expected_config['execution_map_path']),
            'map_expiration_period' => 0
          )
      end
    end
  end

  describe '.run' do
    subject { described_class.run([]) }
    let(:prediction_builder) do
      instance_double('Crystalball::RSpec::PredictionBuilder', prediction: compact_prediction, expired_map?: false)
    end
    let(:compact_prediction) { %w[test test2] }

    before do
      allow_any_instance_of(described_class).to receive(:setup)
      allow(described_class).to receive(:prediction_builder).and_return prediction_builder
      allow_any_instance_of(described_class).to receive(:setup)
    end

    it 'runs rspec with prediction' do
      expect(RSpec::Core::ConfigurationOptions).to receive(:new).with(%w[test test2]).and_call_original

      subject
    end

    context 'with examples_limit set' do
      before do
        ENV['CRYSTALBALL_EXAMPLES_LIMIT'] = '1'
      end

      after { ENV.delete('CRYSTALBALL_EXAMPLES_LIMIT') }

      it 'runs pruned prediction matching the limit' do
        expect(RSpec::Core::ConfigurationOptions).to receive(:new).with(['test']).and_call_original
        subject
      end
    end

    context 'with expired map' do
      before do
        allow(prediction_builder).to receive(:expired_map?).and_return true
        allow(Crystalball).to receive(:log)
      end

      it 'prints out warning' do
        expect(Crystalball).to receive(:log).with(:warn, 'Maps are outdated!')
        described_class.run([], STDERR, STDOUT)
      end
    end
  end

  describe '#setup' do
    subject { runner.setup(STDOUT, STDOUT) }
    let!(:runner) { described_class.new(options, configuration, world) }
    let(:options) { instance_double('RSpec::Core::ConfigurationOptions', options: {files_or_directories_to_run: files}).as_null_object }
    let(:world) { instance_double('RSpec::Core::World', filtered_examples: []).as_null_object }
    let(:configuration) { instance_double('RSpec::Core::Configuration').as_null_object }
    let(:files) { %w[./spec/foo_spec.rb[1:1] ./spec/foo_spec.rb] }

    before do
      allow(Crystalball::RSpec::Filtering).to receive(:remove_unnecessary_filters).with(configuration, files)
    end

    it 'removes the unecessary filters' do
      expect(Crystalball::RSpec::Filtering)
        .to receive(:remove_unnecessary_filters).with(configuration, files)
      subject
    end

    context 'without examples_limit set' do
      it 'runs with world ordered example groups' do
        expect(runner).not_to receive(:reconfigure_to_limit)
        subject
      end
    end

    context 'with examples_limit set' do
      before do
        ENV['CRYSTALBALL_EXAMPLES_LIMIT'] = '1'

        allow(Crystalball::RSpec::PredictionPruning::ExamplesPruner)
          .to receive(:new).with(world, to: 1).and_return double(pruned_set: ['pruned_set'])
        allow(world).to receive(:example_count).and_return(2)
      end
      after { ENV.delete('CRYSTALBALL_EXAMPLES_LIMIT') }

      it 'reconfigures RSpec env with new set from ExamplesPruner' do
        expect(::RSpec::Core::ConfigurationOptions).to receive(:new).with(['pruned_set']).and_return(double.as_null_object)
        expect(world.filtered_examples).to receive(:clear)
        expect(world).to receive(:reset)
        world.instance_variable_set(:@example_group_counts_by_spec_file, [])
        expect(world.instance_variable_get(:@example_group_counts_by_spec_file)).to receive(:clear)

        expect(configuration).to receive(:reset)
        expect(configuration).to receive(:reset_filters)
        subject
      end
    end
  end
end
