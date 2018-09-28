# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator::Configuration do
  let(:default_map_path) { Pathname('tmp/crystalball_data.yml') }

  it 'has default configuration' do
    is_expected.to have_attributes(
      map_storage: an_instance_of(Crystalball::MapStorage::YAMLStorage).and(have_attributes(path: default_map_path)),
      map_storage_path: default_map_path,
      map_class: Crystalball::ExecutionMap,
      dump_threshold: 100,
      strategies: an_instance_of(Crystalball::MapGenerator::StrategiesCollection)
    )
  end

  describe '#dump_threshold=' do
    it 'converts to integer' do
      subject.dump_threshold = '10'
      expect(subject.dump_threshold).to eq(10)
    end
  end

  describe '#map_storage_path=' do
    it 'converts map storage path to pathname' do
      subject.map_storage_path = 'my_map.yml'
      expect(subject.map_storage_path).to eq(Pathname('my_map.yml'))
    end
  end

  describe '#register' do
    let(:strategy) { double(after_register: true) }
    it 'adds a strategy to collection' do
      expect do
        subject.register strategy
      end.to change { subject.strategies.to_a }.to [strategy]
    end

    it 'runs "after_register" callback for a strategy' do
      expect(strategy).to receive(:after_register).once
      subject.register strategy
    end
  end
end
