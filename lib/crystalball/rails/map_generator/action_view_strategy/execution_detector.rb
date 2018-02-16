# frozen_string_literal: true

require_relative '../../../map_generator/concerns/paths_filter'

module Crystalball
  module Rails
    class MapGenerator
      class ActionViewStrategy
        # Class for detecting view relative paths
        class ExecutionDetector
          include ::Crystalball::MapGenerator::Concerns::PathsFilter

          attr_reader :root_path

          # @param [String] absolute path to root folder of repository
          def initialize(root_path)
            @root_path = root_path
          end

          alias detect filter
        end
      end
    end
  end
end
