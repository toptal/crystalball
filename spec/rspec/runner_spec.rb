# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::RSpec::Runner do
  subject { described_class }

  let(:map) { instance_double('Crystalball::MapStorage::YAMLStorage') }

  before do
    described_class.reset!
    allow(Crystalball::MapStorage::YAMLStorage).to receive(:load).and_return(map)
    allow_any_instance_of(described_class).to receive(:setup).and_return 0
    allow(RSpec::Core::ExampleGroup).to receive(:run).and_return 0
  end

  describe '.prepare' do
    let(:expected_config) { {'execution_map_path' => 'map.yml', 'map_expiration_period' => 0, 'prediction_builder_class_name' => 'Crystalball::RSpec::PredictionBuilder'} }
    let(:config_content) { expected_config.to_yaml }

    before do
      allow(Pathname).to receive(:new).and_call_original
      allow_any_instance_of(Crystalball::RSpec::PredictionBuilder).to receive(:expired_map?).and_return(false)
    end

    context 'with CRYSTALBALL_CONFIG env variable set' do
      let(:expected_config) { YAML.safe_load(Pathname('spec/fixtures/crystalball.yml').read) }

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
      allow(described_class).to receive(:prediction_builder).and_return prediction_builder
    end

    it 'runs rspec with prediction' do
      expect(RSpec::Core::ConfigurationOptions).to receive(:new).with(%w[test test2]).and_call_original

      subject
    end

    context 'with examples_limit set' do
      before do
        ENV['CRYSTALBALL_CONFIG'] = 'spec/fixtures/crystalball.yml'
      end

      after { ENV.delete('CRYSTALBALL_CONFIG') }

      it 'runs pruned prediction matching the limit' do
        expect(RSpec::Core::ConfigurationOptions).to receive(:new).with(['test']).and_call_original
        subject
      end
    end

    context 'with expired map' do
      before { allow(prediction_builder).to receive(:expired_map?).and_return true }

      let(:out_stream) { double(puts: true) }

      it 'prints out warning' do
        expect(out_stream).to receive(:puts).with('Maps are outdated!')
        described_class.run([], STDERR, out_stream)
      end
    end
  end

  describe '#run' do
    subject(:runner) { described_class.new({}, RSpec.configuration, world) }
    let(:world) { instance_double('RSpec::Core::World') }
    let(:options) { ConfigurationOptions.new('test', 'test2') }

    before do
      allow(subject).to receive(:persist_example_statuses).and_return false
      allow(world).to receive(:ordered_example_groups).and_return(%w[a b])
    end

    context 'without examples_limit set' do
      it 'runs with world ordered example groups' do
        expect(runner).to receive(:run_specs).with(%w[a b]).and_return(true)
        runner.run(STDOUT, STDOUT)
      end
    end

    context 'with examples_limit set' do
      before do
        ENV['CRYSTALBALL_CONFIG'] = 'spec/fixtures/crystalball.yml'
      end

      after { ENV.delete('CRYSTALBALL_CONFIG') }

      it 'returns whatever ExamplesPruner returns' do
        pruner = double(world_groups: %w[a b], pruned_groups: ['pruned_groups'])
        allow(Crystalball::RSpec::ExamplesPruner).to receive(:new).with(world, to: 1).and_return pruner
        allow(world).to receive(:example_count).and_return(2)

        expect(runner).to receive(:run_specs).with(['pruned_groups']).and_return(true)
        runner.run(STDOUT, STDOUT)
      end
    end
  end
end
