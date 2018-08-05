# frozen_string_literal: true

module Crystalball
  class MapGenerator
    class ObjectSourcesDetector
      # Class to save paths to classes and modules definitions during code loading. Should be
      # started as soon as possible. Use #constants_definition_paths to fetch traced info
      class DefinitionTracer
        attr_reader :trace_point, :constants_definition_paths, :root_path

        def initialize(root_path)
          @root_path = root_path
          @constants_definition_paths = {}
        end

        def start
          self.trace_point ||= TracePoint.new(:class) do |tp|
            mod = tp.self
            path = tp.path

            next if path.nil? || !path.start_with?(root_path)

            constants_definition_paths[mod] ||= []
            constants_definition_paths[mod] << path
          end.tap(&:enable)
        end

        def stop
          trace_point.disable if trace_point.respond_to?(:disable)
          self.trace_point = nil
        end

        protected

        attr_writer :trace_point, :constants_definition_paths
      end
    end
  end
end
