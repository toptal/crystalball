# frozen_string_literal: true

require 'spec_helper'

describe Crystalball do
  describe '.foresee' do
    let(:map_data) { double('map_data') }
    let(:storage) { instance_double(Crystalball::MapStorage::YAMLStorage, load: map_data) }
    let(:source_diff) { instance_double(Crystalball::SourceDiff) }
    let(:predictor) { instance_double(Crystalball::Predictor) }

    before do
      allow(Crystalball::MapStorage::YAMLStorage).to receive(:new).with(Pathname('execution_map.yml')).and_return(storage)
      allow(Crystalball::SourceDiff).to receive(:new).with('.').and_return(source_diff)
    end

    it 'initializes predictor and returns cases' do
      expect(Crystalball::Predictor).to receive(:new).with(map_data, source_diff).and_return(predictor)
      expect(predictor).to receive(:cases)
      described_class.foresee
    end
  end
end
