# frozen_string_literal: true

module Crystalball
  module Rails
    class MapGenerator
      class ActionViewStrategy
        # Class for detecting code execution path based on coverage information diff
        class ExecutionDetector
          attr_reader :root_path

          def initialize(root_path)
            @root_path = root_path
          end

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
