# frozen_string_literal: true

module Crystalball
  class MapGenerator
    # Class for managing files paths
    class ExecutionDetector
      attr_reader :root_path

      # @param [String] absolute path to root folder of repository
      def initialize(root_path)
        @root_path = root_path
      end

      # Transforms absolute paths to relative. Exclude paths outside of root_path
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
