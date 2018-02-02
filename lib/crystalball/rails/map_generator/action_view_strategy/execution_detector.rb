# frozen_string_literal: true

module Crystalball
  module Rails
    class MapGenerator
      class ActionViewStrategy
        # Class for detecting view relative paths
        class ExecutionDetector
          attr_reader :root_path

          def initialize(root_path)
            @root_path = root_path
          end

          # Transforms absolute paths to relative. Exclude paths outside of project
          #
          # @param[Array<String>] list of paths to process
          # @return [Array<String>]
          def detect(paths)
            paths
              .select { |file_name| file_name.start_with?(root_path) }
              .map { |file_name| file_name.sub("#{root_path}/", '') }
          end
        end
      end
    end
  end
end
