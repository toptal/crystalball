# frozen_string_literal: true

require 'rails_helper'

describe Crystalball::Rails::TablesMapGenerator::Configuration do
  let(:default_map_path) { Pathname('tables_map.yml') }
  let(:root_path) { Dir.pwd }

  it 'has default configuration' do
    is_expected.to have_attributes(
      map_storage: an_instance_of(Crystalball::MapStorage::YAMLStorage).and(have_attributes(path: default_map_path)),
      map_storage_path: default_map_path,
      root_path: root_path,
      object_sources_detector: an_instance_of(Crystalball::MapGenerator::ObjectSourcesDetector).and(have_attributes(root_path: root_path))
    )
  end

  describe '#map_storage_path=' do
    it 'converts map storage path to pathname' do
      subject.map_storage_path = 'my_map.yml'
      expect(subject.map_storage_path).to eq(Pathname('my_map.yml'))
    end
  end
end
