# frozen_string_literal: true

module Crystalball
  class MapGenerator
    class AllocatedObjectsStrategy
      # Class to get full hierarchy of a class(including singleton_class)
      class HierarchyLister
        DEFAULT_STOP_CLASSES = [Object, BasicObject].freeze

        attr_reader :stop_classes

        # @param Array[String] stop_classes list of classes which will be used to stop hierarchy lookup
        def initialize(stop_classes = DEFAULT_STOP_CLASSES)
          @stop_classes = stop_classes
        end

        # @param Class klass
        # @return Array[Class] list of ancestors of a klass
        def ancestors_for(klass)
          (pick_ancestors(klass) + pick_ancestors(klass.singleton_class)).uniq
        end

        private

        def pick_ancestors(klass)
          ancestors = klass.ancestors
          index = ancestors.index { |k| stop_classes.include?(k) } || ancestors.size
          ancestors[0...index]
        end
      end
    end
  end
end
