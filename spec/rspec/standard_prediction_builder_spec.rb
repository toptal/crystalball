# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::RSpec::StandardPredictionBuilder do
  subject(:builder) { described_class.new(Crystalball::RSpec::Runner::Configuration.new(configuration)) }
  let(:configuration) do
    {
      'repo_path' => 'test',
      'diff_from' => 'HEAD~3',
      'diff_to' => 'HEAD'
    }
  end

  let(:map) { instance_double('Crystalball::ExecutionMap') }
  let(:repo) { double }

  before do
    allow(Crystalball::MapStorage::YAMLStorage).to receive(:load).with(Pathname('tmp/crystalball_data.yml')).and_return(map)
    allow(Crystalball::GitRepo).to receive(:open).with(Pathname('test')).and_return(repo)
  end

  describe '#prediction' do
    let(:predictor) { instance_double('Crystalball::Predictor', prediction: prediction, use: nil) }
    let(:prediction) { double }

    it 'builds predictor according to config and returns its prediction' do
      allow(Crystalball::Predictor).to receive(:new).with(map, repo, from: 'HEAD~3', to: 'HEAD').and_yield(predictor).and_return(predictor)

      expect(builder.prediction).to eq prediction
    end
  end
end
