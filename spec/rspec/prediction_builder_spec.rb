# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::RSpec::PredictionBuilder do
  subject(:builder) { described_class.new(Crystalball::RSpec::Runner::Configuration.new(configuration)) }
  let(:configuration) { {'repo_path' => 'test'} }

  let(:map) { instance_double('Crystalball::ExecutionMap') }
  let(:repo) { double }

  before do
    allow(Crystalball::MapStorage::YAMLStorage).to receive(:load).with(Pathname('tmp/execution_map.yml')).and_return(map)
    allow(Crystalball::GitRepo).to receive(:open).with(Pathname('test')).and_return(repo)
  end

  describe '#repo' do
    it 'opens a GitRepo with the given path' do
      expect(Crystalball::GitRepo).to receive(:open).with(Pathname('test'))
      builder.repo
    end
  end

  describe '#prediction' do
    it 'raises NotImplementedError by default' do
      expect { builder.prediction }.to raise_error NotImplementedError
    end

    context 'with predictor configured' do
      before do
        builder.define_singleton_method(:predictor) do
          super() {}
        end
      end

      it 'delegates to predictor' do
        expected_prediction = double
        allow_any_instance_of(Crystalball::Predictor).to receive(:prediction).and_return expected_prediction
        expect(builder.prediction).to eq expected_prediction
      end
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

      before { allow(map).to receive(:timestamp).and_return(timestamp) }

      context 'when commit exists in the working tree' do
        context 'and map commit is too old' do
          let(:timestamp) { Time.now.to_i - 10 }

          it { is_expected.to eq true }
        end

        context 'and map commit is fresh enough' do
          let(:timestamp) { Time.now.to_i - 9 }

          it { is_expected.to eq false }
        end
      end
    end
  end
end
