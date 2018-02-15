# frozen_string_literal: true

require 'pry'
require 'crystalball/map_generator/base_strategy'

module Crystalball
  class MapGenerator
    class LoadedObjectsStrategy
      include BaseStrategy

      def initialize
        @finalaized = []
      end

      def call(case_map)
        before = collect_objects
        yield case_map
        after = collect_objects
        case_map.push(*detect(before, after))
      end

      private

      IGNORED_CLASSES = [NilClass, TrueClass, FalseClass, Numeric, Time, String, Range, Struct, Array, Hash, IO, Regexp].freeze

      def collect_objects
        objects = []
        ObjectSpace.each_object(Object) do |object|
          objects.push(object) unless IGNORED_CLASSES.any? { |klass| object.is_a?(klass) }
        end
        objects
      end

      def detect(before, after)
        root_path = Dir.pwd
        # More stable but much more slow. Complexity o(n*n)
        diff = after.reject { |obj| before.find { |_obj| obj.object_id == _obj.object_id } }

        # this approach doesnt work at all. problem with ids
        # last = before.last.object_id
        # index = after.index { |obj| obj.object_id == last }
        # diff = after[index..-1]

        classes = diff.map do |object|
          object.is_a?(Class) ? object : object.class
        end.uniq

        wrapped_classes = classes.map { |klass| Pry::WrappedModule(klass) }

        project_classes = wrapped_classes.select do |wrapped|
          wrapped.source_file&.start_with?(root_path)
        end.compact

        files = project_classes.flat_map do |wrapped|
          wrapped.candidates.flat_map do |candidate|
            candidate.send(:first_method_source_location).first
          end
        end.uniq

        files.select { |file| file.start_with?(root_path) }
      end
    end
  end
end
