# frozen_string_literal: true

require 'crystalball/map_generator/base_strategy'
require 'crystalball/map_generator/execution_detector'

module Crystalball
  class MapGenerator
    # Map generator strategy to collect all objects allocated during test example and
    # get paths to files with defeniton of class and included modules.
    class AllocatedObjectsStrategy
      include BaseStrategy

      attr_reader :execution_detector

      def initialize(execution_detector = ExecutionDetector.new(Dir.pwd))
        @execution_detector = execution_detector
      end

      def after_register
        self.constants_definition_paths = {}
        self.trace_point = TracePoint.new(:class) do |tp|
          class_name = tp.binding.eval('name')
          next unless class_name && tp.path
          constants_definition_paths[class_name] = tp.path
        end
        trace_point.enable
      end

      def before_finalize
        trace_point.disable
      end

      def call(case_map)
        GC.start
        GC.disable

        self.existed_objects_ids = collect_objects_ids

        yield case_map

        case_map.push(*execution_detector.detect(fetch_paths_for_objects))

        GC.enable
      end

      private

      IGNORED_CLASSES = [
        NilClass, TrueClass, FalseClass, Numeric,
        Time, String, Range, Struct, Array, Hash, IO, Regexp
      ].freeze

      attr_accessor :existed_objects_ids, :trace_point, :constants_definition_paths

      def collect_objects_ids
        objects = Set.new

        ObjectSpace.each_object(Object) do |object|
          next if ignore?(object)
          objects << object.__id__
        end

        objects
      end

      def fetch_paths_for_objects
        objects = fetch_new_objects

        classes = objects.map do |object|
          object.is_a?(Class) ? object : object.class
        end.uniq

        classes.flat_map do |klass|
          ancestors = klass.ancestors
          index = ancestors.index(Object) || ancestors.index(BasicObject)
          ancestors = ancestors[0...index]
          ancestors.map { |ancestor| constants_definition_paths[ancestor.name] }
        end.compact
      end

      def fetch_new_objects
        new_objects = []
        ObjectSpace.each_object(Object) do |object|
          next if ignore?(object) ||
                  existed_objects_ids.include?(object.__id__)

          new_objects << object
        end
        new_objects
      end

      def ignore?(object)
        IGNORED_CLASSES.include?(object.class)
      end
    end
  end
end
