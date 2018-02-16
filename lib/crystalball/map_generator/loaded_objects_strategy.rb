# frozen_string_literal: true

require 'pry'
require 'objspace'
require 'crystalball/map_generator/base_strategy'
require 'crystalball/map_generator/loaded_objects_strategy/execution_detector'

module Crystalball
  class MapGenerator
    class LoadedObjectsStrategy
      include BaseStrategy

      attr_reader :execution_detector

      def initialize(execution_detector = ExecutionDetector.new(Dir.pwd))
        @finalaized = []
        @execution_detector = execution_detector
      end

      def call(case_map)
        GC.start
        GC.disable

        self.existed_objects_ids = collect_objects_ids
        ObjectSpace.trace_object_allocations_start

        yield case_map
        case_map.push(*execution_detector.detect(fetch_new_objects))

        ObjectSpace.trace_object_allocations_stop
        ObjectSpace.trace_object_allocations_clear
        GC.enable
        GC.start
      end

      private

      IGNORED_CLASSES = [NilClass, TrueClass, FalseClass, Numeric, Time, String, Range, Struct, Array, Hash, IO, Regexp].freeze

      attr_accessor :existed_objects_ids

      def collect_objects_ids
        objects = {}
        ObjectSpace.each_object(Object) do |object|
          next if IGNORED_CLASSES.include?(object.class)
          objects[object.__id__/1000] ||= []
          objects[object.__id__/1000] << object.__id__
        end
        objects
      end

      def fetch_new_objects
        new_objects = []
        ObjectSpace.each_object.to_a.each do |object|
          next if IGNORED_CLASSES.include?(object.class)
          next if ObjectSpace.allocation_sourcefile(object).nil?
          next if ObjectSpace.allocation_sourcefile(object) == __FILE__
          next if existed_objects_ids[object.__id__ / 1000] &&
            existed_objects_ids[object.__id__ / 1000].include?(object.__id__)
          next if

          new_objects << object
        end
        new_objects
      end
    end
  end
end
