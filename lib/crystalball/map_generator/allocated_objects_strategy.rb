# frozen_string_literal: true

require 'crystalball/map_generator/base_strategy'
require 'crystalball/map_generator/allocated_objects_strategy/execution_detector'
require 'crystalball/map_generator/allocated_objects_strategy/object_tracker'

module Crystalball
  class MapGenerator
    # Map generator strategy to get paths to files contains definition for all objects and its
    # ancestors allocated during test example.
    class AllocatedObjectsStrategy
      include BaseStrategy
      extend Forwardable

      attr_reader :execution_detector, :object_tracker

      delegate %i[after_register before_finalize] => :execution_detector

      def self.build(only: [], root: Dir.pwd)
        hierarchy_fetcher = HierarchyFetcher.new(only)
        execution_detector = ExecutionDetector.new(root_path: root, hierarchy_fetcher: hierarchy_fetcher)

        new(execution_detector: execution_detector, object_tracker: ObjectTracker.new(only_of: only))
      end

      def initialize(execution_detector:, object_tracker:)
        @object_tracker = object_tracker
        @execution_detector = execution_detector
      end

      def call(case_map)
        GC.start
        GC.disable

        objects = object_tracker.created_during do
          yield case_map
        end

        case_map.push(*execution_detector.detect(objects))

        GC.enable
      end
    end
  end
end
