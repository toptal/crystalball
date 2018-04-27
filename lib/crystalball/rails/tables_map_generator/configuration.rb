# frozen_string_literal: true

require 'crystalball/map_generator/object_sources_detector'

module Crystalball
  module Rails
    class TablesMapGenerator
      # Configuration of tables map generator. Is can be accessed as a first argument inside
      # `Crystalball::Rails::TablesMapGenerator.start! { |config| config } block.
      class Configuration
        attr_writer :map_storage
        attr_accessor :commit
        attr_accessor :version
        attr_writer :root_path
        attr_writer :object_sources_detector

        def map_storage_path
          @map_storage_path ||= Pathname('tables_map.yml')
        end

        def map_storage_path=(value)
          @map_storage_path = Pathname(value)
        end

        def map_storage
          @map_storage ||= MapStorage::YAMLStorage.new(map_storage_path)
        end

        def root_path
          @root_path ||= Dir.pwd
        end

        def object_sources_detector
          @object_sources_detector ||= ::Crystalball::MapGenerator::ObjectSourcesDetector.new(root_path: root_path)
        end
      end
    end
  end
end
