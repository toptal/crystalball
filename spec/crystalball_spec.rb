# frozen_string_literal: true

require 'spec_helper'

describe Crystalball do
  describe '.foresee' do
    let(:map) { instance_double(Crystalball::ExecutionMap, commit: commit) }
    let(:repo) { instance_double(Crystalball::GitRepo, diff: nil) }
    let(:predictor) { instance_double(Crystalball::Predictor, cases: double) }
    let(:commit) { double }

    before do
      allow(Crystalball::MapStorage::YAMLStorage).to receive(:load).with(Pathname('execution_map.yml')).and_return(map)
      allow(Crystalball::GitRepo).to receive(:new).with(Pathname('.')).and_return(repo)
    end

    it 'initializes predictor and returns cases' do
      allow(Crystalball::Predictor).to receive(:new).with(map, repo, from: commit).and_return(predictor)
      expected_result = double
      allow(predictor).to receive(:cases).and_return(expected_result)

      expect(described_class.foresee).to eq expected_result
    end
  end
end
