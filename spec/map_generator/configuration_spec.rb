# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator::Configuration do
  let(:default_map_path) { Pathname('execution_map.yml') }

  it 'has default configuration' do
    is_expected.to have_attributes(
      execution_detector: an_instance_of(Crystalball::ExecutionDetector).and(have_attributes(root_path: Dir.pwd)),
      map_storage: an_instance_of(Crystalball::MapStorage::YAMLStorage).and(have_attributes(path: default_map_path)),
      map_storage_path: default_map_path,
      dump_threshold: 100
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
end
