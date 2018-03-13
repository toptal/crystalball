# frozen_string_literal: true

require 'crystalball/map_generator/helpers/path_filter'
require 'crystalball/map_generator/object_sources_detector/hierarchy_fetcher'
require 'crystalball/map_generator/object_sources_detector/definition_tracer'

module Crystalball
  class MapGenerator
    # Class for files paths affected object definition
    class ObjectSourcesDetector
      include ::Crystalball::MapGenerator::Helpers::PathFilter

      attr_reader :definition_tracer, :hierarchy_fetcher

      def initialize(
        root_path:,
        definition_tracer: DefinitionTracer.new(root_path),
        hierarchy_fetcher: HierarchyFetcher.new
      )
        super(root_path)

        @definition_tracer = definition_tracer
        @hierarchy_fetcher = hierarchy_fetcher
      end

      def after_register
        definition_tracer.start
      end

      def before_finalize
        definition_tracer.stop
      end

      # Detects files affected during example execution. Transforms absolute paths to relative.
      # Exclude paths outside of repository
      #
      # @param[Array<String>] list of files affected before example execution
      # @return [Array<String>]
      def detect(objects)
        modules = objects.map do |object|
          object.is_a?(Module) ? object : object.class
        end.uniq

        paths = modules.flat_map do |mod|
          hierarchy_fetcher.ancestors_for(mod).flat_map do |ancestor|
            definition_tracer.constants_definition_paths[ancestor]
          end
        end.compact.uniq

        filter paths
      end
    end
  end
end
