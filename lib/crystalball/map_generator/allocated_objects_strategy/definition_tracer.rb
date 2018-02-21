# frozen_string_literal: true

module Crystalball
  class MapGenerator
    class AllocatedObjectsStrategy
      # Class to save paths to classes and modules definitions during code loading. Should be
      # started as soon as possible. Use #constants_definition_paths to fetch traced info
      class DefinitionTracer
        attr_reader :trace_point, :constants_definition_paths

        def initialize
          @constants_definition_paths = {}
        end

        def start
          self.trace_point ||= TracePoint.new(:class) do |tp|
            class_name = tp.binding.eval('name')
            next unless class_name && tp.path
            constants_definition_paths[class_name] ||= []
            constants_definition_paths[class_name] << tp.path
          end.tap(&:enable)
        end

        def stop
          trace_point&.disable
          self.trace_point = nil
        end

        private

        attr_writer :trace_point, :constants_definition_paths
      end
    end
  end
end
