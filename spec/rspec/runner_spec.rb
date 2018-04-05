# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::RSpec::Runner do
  subject { described_class }

  before do
    allow(Crystalball::MapStorage::YAMLStorage).to receive(:load).and_return(instance_double('Crystalball::MapStorage::YAMLStorage'))
    allow_any_instance_of(described_class).to receive(:run).and_return 0
  end

  describe '.invoke' do
    let(:predictor_config) { {'map_expiration_period' => 0} }

    it 'configures predictor' do
      expect(described_class).to receive(:setup_prediction_builder).with(predictor_config).and_call_original
      described_class.invoke(predictor_config)
    end
  end

  describe '.run' do
    let(:prediction_builder) do
      instance_double('Crystalball::RSpec::PredictionBuilder', prediction: double(compact: compact_prediction), expired_map?: false)
    end
    let(:compact_prediction) { ['test'] }

    before do
      allow(described_class).to receive(:prediction_builder).and_return prediction_builder
    end

    it 'runs rspec with prediction' do
      expect(RSpec::Core::ConfigurationOptions).to receive(:new).with(['test']).and_call_original

      described_class.run([])
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
end
