# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::RSpec::Runner::Configuration do
  subject(:config) { described_class.new(overrides) }

  context 'by default' do
    let(:overrides) { {} }
    specify do
      expect(config.to_h)
        .to match(
          'execution_map_path' => Pathname('tmp/crystalball_data.yml'),
          'map_expiration_period' => 86_400,
          'repo_path' => Pathname(Dir.pwd),
          'prediction_builder_class_name' => 'Crystalball::RSpec::StandardPredictionBuilder',
          'prediction_builder_class' => Crystalball::RSpec::StandardPredictionBuilder,
          'requires' => [],
          'diff_from' => 'HEAD',
          'diff_to' => nil,
          'runner_class' => Crystalball::RSpec::Runner,
          'runner_class_name' => 'Crystalball::RSpec::Runner',
          'log_level' => :info,
          'log_file' => Pathname('/dev/null')
        )
    end
  end

  context 'with overrides' do
    let(:overrides) do
      {
        'execution_map_path' => 'execution_maps/',
        'repo_path' => 'test',
        'prediction_builder_class_name' => 'MyPredictionBuilder',
        'requires' => ['test.rb'],
        'diff_from' => 'HEAD~3',
        'diff_to' => 'HEAD',
        'map_expiration_period' => 1,
        'runner_class_name' => 'MyRunner',
        'custom' => 42
      }
    end

    before do
      stub_const('MyPredictionBuilder', Class.new)
      stub_const('MyRunner', Class.new)

      # Don't ask me why we need this additional stub, but we really need it.
      allow_any_instance_of(Object).to receive(:require).and_call_original
      allow_any_instance_of(Object).to receive(:require).with('test.rb').and_return true
    end

    it 'allows to set any config attribute' do
      expect(config.to_h)
        .to match(
          'execution_map_path' => Pathname('execution_maps/'),
          'repo_path' => Pathname('test'),
          'prediction_builder_class_name' => 'MyPredictionBuilder',
          'prediction_builder_class' => MyPredictionBuilder,
          'requires' => ['test.rb'],
          'runner_class' => MyRunner,
          'runner_class_name' => 'MyRunner',
          'diff_from' => 'HEAD~3',
          'diff_to' => 'HEAD',
          'map_expiration_period' => 1,
          'log_level' => :info,
          'log_file' => Pathname('/dev/null'),
          'custom' => 42
        )
    end

    it 'returns other custom attributes as is' do
      expect(config['custom']).to eq 42
    end

    context 'with ENV overrides' do
      around do |example|
        value = ENV['CRYSTALBALL_DIFF_FROM']
        begin
          ENV['CRYSTALBALL_DIFF_FROM'] = 'origin/master'
          example.call
        ensure
          ENV['CRYSTALBALL_DIFF_FROM'] = value
        end
      end

      it 'prioritizes ENV variable' do
        expect(config['diff_from']).to eq 'origin/master'
      end
    end
  end
end
