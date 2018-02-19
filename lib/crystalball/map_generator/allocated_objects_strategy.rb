# frozen_string_literal: true

require 'pry'
require 'objspace'
require 'crystalball/map_generator/base_strategy'
require 'crystalball/map_generator/allocated_objects_strategy/execution_detector'

module Crystalball
  class MapGenerator
    # Map generator strategy to collect all objects allocated during test example and
    # get paths to files with defeniton of class and included modules.
    class AllocatedObjectsStrategy
      include BaseStrategy

      attr_reader :execution_detector

      def initialize(execution_detector = ExecutionDetector.new(Dir.pwd))
        @finalaized = []
        @execution_detector = execution_detector
      end

      def call(case_map)
        GC.start
        GC.disable

        collect_objects_ids

        ObjectSpace.trace_object_allocations do
          yield case_map
          case_map.push(*execution_detector.detect(fetch_new_objects))
        end

        ObjectSpace.trace_object_allocations_clear

        GC.enable
        GC.start
      end

      private

      IGNORED_CLASSES = [
        NilClass, TrueClass, FalseClass, Numeric,
        Time, String, Range, Struct, Array, Hash, IO, Regexp
      ].freeze

      attr_accessor :existed_objects_ids

      def collect_objects_ids
        self.existed_objects_ids = {}
        ObjectSpace.each_object(Object) do |object|
          next if ignore?(object)
          allocated_before_example(object)
        end
      end

      def fetch_new_objects
        new_objects = []
        ObjectSpace.each_object(Object) do |object|
          next if ignore?(object) ||
            allocated_not_in_project?(object) ||
            allocated_before_example?(object)

          new_objects << object
        end
        new_objects
      end

      def ignore?(object)
        IGNORED_CLASSES.include?(object.class)
      end

      def allocated_not_in_project?(object)
        allocation_sourcefile = ObjectSpace.allocation_sourcefile(object)
        allocation_sourcefile.nil? || allocation_sourcefile == __FILE__
      end

      def allocated_before_example(object)
        existed_objects_ids[object.__id__ / 1000] ||= []
        existed_objects_ids[object.__id__ / 1000] << object.__id__
      end

      def allocated_before_example?(object)
        existed_objects_ids[object.__id__ / 1000]&.include?(object.__id__)
      end
    end
  end
end
