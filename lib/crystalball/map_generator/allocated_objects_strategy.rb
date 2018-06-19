# frozen_string_literal: true

require 'crystalball/map_generator/base_strategy'
require 'crystalball/map_generator/object_sources_detector'
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
        hierarchy_fetcher = ObjectSourcesDetector::HierarchyFetcher.new(only)
        execution_detector = ObjectSourcesDetector.new(root_path: root, hierarchy_fetcher: hierarchy_fetcher)

        new(execution_detector: execution_detector, object_tracker: ObjectTracker.new(only_of: only))
      end

      # @param [#detect] execution_detector
      # @param [#created_during] object_tracker
      def initialize(execution_detector:, object_tracker:)
        @object_tracker = object_tracker
        @execution_detector = execution_detector
      end

      # Adds to the used files every file which contain the definition of the
      # classes of the objects allocated during the spec execution.
      # @param [Crystalball::ExampleGroupMap] example_map - object holding example metadata and used files
      # @param [RSpec::Core::Example] example - a RSpec example
      def call(example_map, example)
        classes = object_tracker.used_classes_during do
          yield example_map, example
        end
        example_map.push(*execution_detector.detect(classes))
      end
    end
  end
end
