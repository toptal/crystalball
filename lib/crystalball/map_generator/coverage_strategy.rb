# frozen_string_literal: true

require 'coverage'
require 'coverage_peek'
require 'crystalball/map_generator/base_strategy'
require 'crystalball/map_generator/coverage_strategy/execution_detector'

module Crystalball
  class MapGenerator
    # Map generator strategy based on harvesting Coverage information during example execution
    class CoverageStrategy
      include BaseStrategy

      attr_reader :execution_detector

      def initialize(execution_detector = ExecutionDetector.new)
        @execution_detector = execution_detector
      end

      def after_register
        Coverage.start
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
