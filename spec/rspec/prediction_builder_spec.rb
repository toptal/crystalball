# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::RSpec::PredictionBuilder do
  subject(:builder) { described_class.new(configuration) }
  let(:configuration) { {'repo_path' => 'test'} }

  let(:map) { instance_double('Crystalball::ExecutionMap') }
  let(:repo) { double }

  before do
    allow(Crystalball::MapStorage::YAMLStorage).to receive(:load).with(Pathname('tmp/execution_maps')).and_return(map)
    allow(Crystalball::GitRepo).to receive(:open).with(Pathname('test')).and_return(repo)
  end

  describe '#config' do
    context 'by default' do
      let(:configuration) { {} }
      specify do
        expect(subject.config.to_h)
          .to match(
            'map_path' => Pathname('tmp/execution_maps'),
            'map_expiration_period' => 86_400,
            'repo_path' => Pathname(Dir.pwd),
            'predictor_class_name' => 'Crystalball::Predictor',
            'predictor_class' => Crystalball::Predictor,
            'requires' => [],
            'diff_from' => 'HEAD',
            'diff_to' => nil
          )
      end
    end

    context 'with overrides' do
      let(:configuration) do
        {
          'map_path' => 'execution_map.yml',
          'repo_path' => 'test',
          'predictor_class_name' => 'MyPredictor',
          'requires' => ['test.rb'],
          'diff_from' => 'HEAD~3',
          'diff_to' => 'HEAD',
          'map_expiration_period' => 1,
          'custom' => 42
        }
      end

      before do
        # Don't ask me why we need this additional stub, but we really need it.
        allow_any_instance_of(Object).to receive(:require).and_call_original
        allow_any_instance_of(Object).to receive(:require).with('test.rb') do
          stub_const('MyPredictor', Class.new)
        end
      end

      it 'allows to set any config attribute' do
        expect(subject.config.to_h)
          .to match(
            'map_path' => Pathname('execution_map.yml'),
            'repo_path' => Pathname('test'),
            'predictor_class_name' => 'MyPredictor',
            'predictor_class' => MyPredictor,
            'requires' => ['test.rb'],
            'diff_from' => 'HEAD~3',
            'diff_to' => 'HEAD',
            'map_expiration_period' => 1,
            'custom' => 42
          )
      end

      it 'returns other custom attributes as is' do
        expect(subject.config['custom']).to eq 42
      end
    end
  end

  describe '#prediction' do
    let(:configuration) do
      super().merge(
        'predictor_class_name' => 'MyPredictor',
        'diff_from' => 'HEAD~3',
        'diff_to' => 'HEAD'
      )
    end
    let(:base_predictor) { instance_double('MyPredictor', prediction: prediction) }
    let(:prediction) { double }

    before do
      stub_const('MyPredictor', Class.new(Crystalball::Predictor))
    end

    it 'builds base predictor according to config and returns its prediction' do
      allow(MyPredictor).to receive(:new).with(map, repo, from: 'HEAD~3', to: 'HEAD').and_return(base_predictor)

      expect(builder.prediction).to eq prediction
    end
  end

  describe '#expired_map?' do
    subject { builder.expired_map? }
    context 'when expiration configuration is <= 0' do
      let(:configuration) do
        super().merge('map_expiration_period' => 0)
      end

      it { is_expected.to eq false }
    end

    context 'when expiration configuration is > 0', freeze: true do
      let(:configuration) do
        super().merge('map_expiration_period' => 10)
      end
      let(:commit_date) { Time.now - 5 }

      before do
        commit_info = double(date: commit_date)
        map_commit = double
        allow(map).to receive(:commit).and_return(map_commit)
        allow(repo).to receive(:gcommit).with(map_commit).and_return(commit_info)
      end

      context 'and map commit is too old' do
        let(:commit_date) { Time.now - 10 }

        it { is_expected.to eq true }
      end

      context 'and map commit is fresh enough' do
        let(:commit_date) { Time.now - 9 }

        it { is_expected.to eq false }
      end
    end
  end
end
