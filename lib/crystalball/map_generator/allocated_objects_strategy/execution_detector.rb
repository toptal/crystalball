# frozen_string_literal: true

require_relative '../helpers/path_filter'
require 'crystalball/map_generator/allocated_objects_strategy/hierarchy_fetcher'
require 'crystalball/map_generator/allocated_objects_strategy/definition_tracer'

module Crystalball
  class MapGenerator
    class AllocatedObjectsStrategy
      # Class for files paths affected object definition
      class ExecutionDetector
        include ::Crystalball::MapGenerator::Helpers::PathFilter

        attr_reader :definition_tracer, :hierarchy_fetcher

        def initialize(
          definition_tracer: DefinitionTracer.new,
          hierarchy_fetcher: HierarchyFetcher.new,
          root_path: Dir.pwd
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
          classes = objects.map do |object|
            object.is_a?(Class) ? object : object.class
          end.uniq

          paths = classes.flat_map do |klass|
            hierarchy_fetcher.ancestors_for(klass).flat_map do |ancestor|
              definition_tracer.constants_definition_paths[ancestor.name]
            end
          end.compact

          filter paths
        end
      end
    end
  end
end
