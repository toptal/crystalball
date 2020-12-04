# frozen_string_literal: true

require 'crystalball/map_generator/strategies_collection'

module Crystalball
  class MapGenerator
    # Configuration of map generator. Is can be accessed as a first argument inside
    # `Crystalball::MapGenerator.start! { |config| config } block.
    class Configuration
      attr_writer :map_storage
      attr_writer :map_class
      attr_accessor :commit, :version, :compact_map

      attr_reader :strategies
      attr_reader :exclude_sources

      def initialize(exclude_sources: [])
        @exclude_sources = exclude_sources
        @strategies = StrategiesCollection.new
        @compact_map = true
      end

      def compact_map?
        !!@compact_map
      end

      def map_class
        @map_class ||= ExecutionMap
      end

      def map_storage_path
        @map_storage_path ||= Pathname('tmp/crystalball_data.yml')
      end

      def map_storage_path=(value)
        @map_storage_path = Pathname(value)
      end

      def map_storage
        @map_storage ||= MapStorage::YAMLStorage.new(map_storage_path)
      end

      def dump_threshold
        @dump_threshold ||= 100
      end

      def dump_threshold=(value)
        @dump_threshold = value.to_i
      end

      # Register new strategy for map generation
      #
      # @param [Crystalball::MapGenerator::BaseStrategy] strategy
      def register(strategy)
        strategy.exclude_sources = exclude_sources
        @strategies.push strategy
        strategy.after_register
      end
    end
  end
end
