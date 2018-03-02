# frozen_string_literal: true

module Crystalball
  class MapGenerator
    class AllocatedObjectsStrategy
      # Class to list objects from ObjectSpace
      class ObjectTracker
        attr_reader :only_of

        # @param Array[Module] only_of classes or modules to watch on
        def initialize(only_of: [Object])
          @allocated_ids = Set.new
          @only_of = only_of
        end

        # @param Block a block to yield
        # @return Array[Object] objects allocated during the block execution
        def created_during
          store_allocated_ids
          yield
          new_allocated_objects
        end

        private

        attr_accessor :allocated_ids

        def store_allocated_ids
          only_of.each do |mod|
            ObjectSpace.each_object(mod) do |object|
              allocated_ids << object.__id__
            end
          end
        end

        def new_allocated_objects
          objects = []

          only_of.each do |mod|
            ObjectSpace.each_object(mod) do |object|
              next if allocated_ids.include?(object.__id__)

              objects << object
            end
          end

          objects
        end
      end
    end
  end
end
