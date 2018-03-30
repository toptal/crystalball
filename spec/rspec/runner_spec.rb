# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::RSpec::Runner do
  subject { described_class }

  before do
    allow(Crystalball::MapStorage::YAMLStorage).to receive(:load).and_return(instance_double('Crystalball::MapStorage::YAMLStorage'))
    allow_any_instance_of(described_class).to receive(:run).and_return 0
  end

  describe '.invoke' do
    let(:predictor_config) { {} }

    it 'configures predictor' do
      expect(described_class).to receive(:setup_prediction_builder).with(predictor_config).and_call_original
      described_class.invoke(predictor_config)
    end
  end

  describe '.run' do
    let(:prediction_builder) { instance_double('Crystalball::RSpec::PredictionBuilder', prediction: double(compact: compact_prediction)) }
    let(:compact_prediction) { ['test'] }

    before do
      allow(described_class).to receive(:prediction_builder).and_return prediction_builder
    end

    it 'runs rspec with prediction' do
      expect(RSpec::Core::ConfigurationOptions).to receive(:new).with(['test']).and_call_original

      described_class.run([])
    end
  end
end
