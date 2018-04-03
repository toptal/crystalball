# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::RSpec::PredictionBuilder do
  subject(:builder) { described_class.new(configuration) }
  let(:configuration) { {} }

  describe '#config' do
    context 'by default' do
      specify do
        expect(subject.config)
          .to have_attributes(
            map_path: Pathname('tmp/execution_maps'),
            repo_path: Pathname(Dir.pwd),
            predictor_class_name: 'Crystalball::Predictor',
            requires: [],
            diff_from: 'HEAD',
            diff_to: nil
          )
      end
    end

    context 'with overrides' do
      let(:configuration) do
        {
          'map_path' => 'execution_map.yml',
          'repo_path' => 'test',
          'predictor_class' => 'MyPredictor',
          'requires' => ['test.rb'],
          'diff_from' => 'HEAD~3',
          'diff_to' => 'HEAD',
          'custom' => 42
        }
      end
      it 'allows to set any config attribute' do
        expect(subject.config)
          .to have_attributes(
            map_path: Pathname('execution_map.yml'),
            repo_path: Pathname('test'),
            predictor_class_name: 'MyPredictor',
            requires: ['test.rb'],
            diff_from: 'HEAD~3',
            diff_to: 'HEAD'
          )
      end

      it 'returns other custom attributes as is' do
        expect(subject.config).to respond_to(:custom)
        expect(subject.config.custom).to eq 42
      end
    end

    describe '#predictor_class' do
      let(:configuration) do
        {
          'requires' => ['my_predictor.rb'],
          'predictor_class' => 'MyPredictor'
        }
      end
      let(:my_predictor_class) { Class.new }

      it 'requires files before getting a class const' do
        # Don't ask me why we need this additional stub, but we really need it.
        allow_any_instance_of(Object).to receive(:require).and_call_original

        allow_any_instance_of(Object).to receive(:require).with('my_predictor.rb') do
          stub_const('MyPredictor', my_predictor_class)
        end
        expect(builder.config.predictor_class).to eq(my_predictor_class)
      end
    end
  end

  describe '#prediction' do
    let(:configuration) do
      {
        'map_path' => 'execution_map.yml',
        'repo_path' => 'test',
        'predictor_class' => 'MyPredictor',
        'diff_from' => 'HEAD~3',
        'diff_to' => 'HEAD'
      }
    end
    let(:map) { instance_double('Crystalball::ExecutionMap') }
    let(:repo) { instance_double('Crystalball::GitRepo') }
    let(:base_predictor) { instance_double('MyPredictor', prediction: prediction) }
    let(:prediction) { double }

    before do
      stub_const('MyPredictor', Class.new(Crystalball::Predictor))
    end

    it 'builds base predictor according to config and returns its prediction' do
      allow(Crystalball::MapStorage::YAMLStorage).to receive(:load).with(Pathname('execution_map.yml')).and_return(map)
      allow(Crystalball::GitRepo).to receive(:open).with(Pathname('test')).and_return(repo)
      allow(MyPredictor).to receive(:new).with(map, repo, from: 'HEAD~3', to: 'HEAD').and_return(base_predictor)

      expect(builder.prediction).to eq prediction
    end
  end
end
