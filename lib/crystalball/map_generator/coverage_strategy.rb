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

      def initialize(execution_detector = ExecutionDetector.new)
        @execution_detector = execution_detector
      end

      def after_register
        Coverage.start
      end

      # Adds to the case_map's affected files the ones the ones in which
      # the coverage has changed after the tests runs.
      # @param [Crystalball::CaseMap] object holding example metadata and affected files
      def call(case_map, _)
        before = Coverage.peek_result
        yield case_map
        after = Coverage.peek_result
        case_map.push(*execution_detector.detect(before, after))
      end
    end
  end
end
