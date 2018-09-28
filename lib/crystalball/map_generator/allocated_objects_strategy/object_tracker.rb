# frozen_string_literal: true

require 'set'

module Crystalball
  class MapGenerator
    class AllocatedObjectsStrategy
      # Class to list object classes used during a block
      class ObjectTracker
        attr_reader :only_of

        # @param [Array<Module>] only_of - classes or modules to watch on
        def initialize(only_of: ['Object'])
          @only_of = only_of
          @created_object_classes = Set.new
        end

        # @yield a block to execute
        # @return [Array<Object>] classes of objects allocated during the block execution
        def used_classes_during(&block)
          self.created_object_classes = Set.new
          trace_point.enable(&block)
          created_object_classes
        end

        private

        attr_accessor :created_object_classes

        def whitelisted_constants
          @whitelisted_constants ||= only_of.map { |str| Object.const_get(str) }
        end

        def trace_point
          @trace_point ||= TracePoint.new(:c_call) do |tp|
            next unless tp.method_id == :new || tp.method_id == :allocate
            next unless whitelisted_constants.any? { |c| tp.self <= c }

            created_object_classes << tp.self
          end
        end
      end
    end
  end
end
