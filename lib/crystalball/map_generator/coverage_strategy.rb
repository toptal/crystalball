# frozen_string_literal: true

require 'coverage'
require 'crystalball/map_generator/base_strategy'
require 'crystalball/map_generator/coverage_strategy/execution_detector'

module Crystalball
  class MapGenerator
    # Map generator strategy based on harvesting Coverage information during example execution
    class CoverageStrategy
      include BaseStrategy

      attr_reader :execution_detector
      attr_reader :exclude_sources

      def initialize(execution_detector = ExecutionDetector.new)
        @execution_detector = execution_detector
      end

      def exclude_sources=(value)
        @exclude_sources = value
        @execution_detector.exclude_sources = value
      end

      def after_register
        Coverage.start unless Coverage.running?
      end

      # Adds to the example_map's used files the ones the ones in which
      # the coverage has changed after the tests runs.
      # @param [Crystalball::ExampleGroupMap] example_map - object holding example metadata and used files
      # @param [RSpec::Core::Example] example - a RSpec example
      def call(example_map, example)
        before = Coverage.peek_result
        yield example_map, example
        after = Coverage.peek_result
        example_map.push(*execution_detector.detect(before, after))
      end
    end
  end
end
