# frozen_string_literal: true

module Crystalball
  class MapGenerator
    class AllocatedObjectsStrategy
      # Class to list objects from ObjectSpace
      class ObjectTracker
        attr_reader :ignored_types

        DEFAULT_IGNORED_TYPES = [
          NilClass, TrueClass, FalseClass, Numeric, String, Regexp,
          Range, Array, Hash, Struct, Time, IO
        ].freeze

        # @param Array[Class] ignored_types classes which will be excluded from list
        def initialize(ignored_types = DEFAULT_IGNORED_TYPES)
          @ignored_types = ignored_types
        end

        # @return Set[Integer] object_id list of allocated objects except ignored
        def list_ids
          objects = Set.new

          ObjectSpace.each_object(Object) do |object|
            next if ignored_types.include?(object.class)
            objects << object.__id__
          end

          objects
        end

        # @param Set[Integer] except_ids ids of objects which should be excluded from the list
        # @return Array[Object] list of allocated objects except ignored and excluded
        def list(except_ids: Set.new)
          objects = []

          ObjectSpace.each_object(Object) do |object|
            next if ignored_types.include?(object.class) ||
                    except_ids.include?(object.__id__)

            objects << object
          end

          objects
        end

        # @param Block a block to yield
        # @return Array[Object] objects allocated during the block execution
        def created_during
          ids = list_ids
          yield
          list(except_ids: ids)
        end

        private

        attr_writer :ignored_types
      end
    end
  end
end
