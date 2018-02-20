# frozen_string_literal: true

require 'crystalball/map_generator/base_strategy'
require 'crystalball/map_generator/execution_detector'
require 'crystalball/map_generator/allocated_objects_strategy/object_lister'
require 'crystalball/map_generator/allocated_objects_strategy/definition_tracer'
require 'crystalball/map_generator/allocated_objects_strategy/hierarchy_lister'

module Crystalball
  class MapGenerator
    # Map generator strategy to get paths to files contains defenition for all objects and its
    # ancestors allocated during test example.
    class AllocatedObjectsStrategy
      include BaseStrategy

      attr_reader :execution_detector, :definition_tracer, :object_lister, :hierarchy_lister

      def initialize(
        execution_detector: ExecutionDetector.new(Dir.pwd),
        object_lister: ObjectLister.new,
        definition_tracer: DefinitionTracer.new,
        hierarchy_lister: HierarchyLister.new
      )
        @execution_detector = execution_detector
        @object_lister = object_lister
        @definition_tracer = definition_tracer
        @hierarchy_lister = hierarchy_lister
      end

      def after_register
        definition_tracer.start
      end

      def before_finalize
        definition_tracer.stop
      end

      def call(case_map)
        GC.start
        GC.disable

        objects = object_lister.created_during do
          yield case_map
        end

        paths = fetch_paths_for_objects(objects)
        case_map.push(*execution_detector.detect(paths))

        GC.enable
      end

      private

      def fetch_paths_for_objects(objects)
        classes = objects.map do |object|
          object.is_a?(Class) ? object : object.class
        end.uniq

        classes.flat_map do |klass|
          hierarchy_lister.ancestors_for(klass).map do |ancestor|
            definition_tracer.constants_definition_paths[ancestor.name]
          end
        end.compact
      end
    end
  end
end
