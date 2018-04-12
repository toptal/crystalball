# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::RSpec::Runner::Configuration do
  subject(:config) { described_class.new(overrides) }

  context 'by default' do
    let(:overrides) { {} }
    specify do
      expect(config.to_h)
        .to match(
          'map_path' => Pathname('tmp/execution_maps'),
          'map_expiration_period' => 86_400,
          'repo_path' => Pathname(Dir.pwd),
          'predictor_class_name' => 'Crystalball::Predictor',
          'predictor_class' => Crystalball::Predictor,
          'requires' => [],
          'diff_from' => 'HEAD',
          'diff_to' => nil,
          'runner_class' => Crystalball::RSpec::Runner,
          'runner_class_name' => 'Crystalball::RSpec::Runner'
        )
    end
  end

  context 'with overrides' do
    let(:overrides) do
      {
        'map_path' => 'execution_map.yml',
        'repo_path' => 'test',
        'predictor_class_name' => 'MyPredictor',
        'requires' => ['test.rb'],
        'diff_from' => 'HEAD~3',
        'diff_to' => 'HEAD',
        'map_expiration_period' => 1,
        'runner_class_name' => 'MyRunner',
        'custom' => 42
      }
    end

    before do
      stub_const('MyPredictor', Class.new)
      stub_const('MyRunner', Class.new)

      # Don't ask me why we need this additional stub, but we really need it.
      allow_any_instance_of(Object).to receive(:require).and_call_original
      allow_any_instance_of(Object).to receive(:require).with('test.rb').and_return true
    end

    it 'allows to set any config attribute' do
      expect(config.to_h)
        .to match(
          'map_path' => Pathname('execution_map.yml'),
          'repo_path' => Pathname('test'),
          'predictor_class_name' => 'MyPredictor',
          'predictor_class' => MyPredictor,
          'requires' => ['test.rb'],
          'runner_class' => MyRunner,
          'runner_class_name' => 'MyRunner',
          'diff_from' => 'HEAD~3',
          'diff_to' => 'HEAD',
          'map_expiration_period' => 1,
          'custom' => 42
        )
    end

    it 'returns other custom attributes as is' do
      expect(config['custom']).to eq 42
    end
  end
end
