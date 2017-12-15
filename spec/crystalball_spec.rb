# frozen_string_literal: true

require 'spec_helper'

describe Crystalball do
  describe '.foresee' do
    let(:map) { instance_double(Crystalball::MapGenerator::StandardMap) }
    let(:storage) { instance_double(Crystalball::MapStorage::YAMLStorage, load: map) }
    let(:repo) { instance_double(Crystalball::GitRepo, source_diff: source_diff) }
    let(:source_diff) { instance_double(Crystalball::SourceDiff) }
    let(:predictor) { instance_double(Crystalball::Predictor, cases: double) }

    before do
      allow(Crystalball::MapStorage::YAMLStorage).to receive(:new).with(Pathname('execution_map.yml')).and_return(storage)
      allow(Crystalball::GitRepo).to receive(:new).with('.').and_return(repo)
    end

    it 'initializes predictor and returns cases' do
      allow(Crystalball::Predictor).to receive(:new).with(map, source_diff).and_return(predictor)
      expected_result = double
      expect(predictor).to receive(:cases).and_return(expected_result)

      result = described_class.foresee do |p|
        expect(p).to eq(predictor)
      end
      expect(result).to eq expected_result
    end
  end
end
