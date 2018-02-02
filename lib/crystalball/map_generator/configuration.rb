# frozen_string_literal: true

require 'crystalball/map_generator/strategies_collection'

module Crystalball
  class MapGenerator
    # Configuration of map generator. Is can be accessed as a first argument inside
    # `Crystalball::MapGenerator.start! { |config| config } block.
    class Configuration
      attr_writer :map_storage
      attr_accessor :commit

      attr_reader :strategies

      def initialize
        @strategies = StrategiesCollection.new
      end

      def map_storage_path
        @map_storage_path ||= Pathname('execution_map.yml')
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

      def register(strategy)
        @strategies.push strategy
        strategy.after_register
      end
    end
  end
end
