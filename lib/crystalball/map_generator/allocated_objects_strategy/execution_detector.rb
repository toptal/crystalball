# frozen_string_literal: true

require_relative '../concerns/paths_filter'

module Crystalball
  class MapGenerator
    class AllocatedObjectsStrategy
      # Class for detecting paths from objects
      class ExecutionDetector
        include ::Crystalball::MapGenerator::Concerns::PathsFilter

        attr_reader :root_path

        # @param [String] absolute path to root folder of repository
        def initialize(root_path)
          @root_path = root_path
        end

        # Fetches relative paths of all objects declarations
        #
        # @param[Array<Object>] list of objects to process
        # @return [Array<String>]
        def detect(objects)
          classes = objects.map do |object|
            object.is_a?(Class) ? object : object.class
          end.uniq

          wrapped_classes = classes.map { |klass| Pry::WrappedModule(klass) }

          project_classes = wrapped_classes.select do |wrapped|
            wrapped.source_file&.start_with?(root_path)
          end.compact

          paths = project_classes.flat_map do |wrapped|
            wrapped.candidates.flat_map do |candidate|
              candidate.send(:first_method_source_location).first
            end
          end.uniq

          filter paths
        end
      end
    end
  end
end
