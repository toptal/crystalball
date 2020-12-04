# frozen_string_literal: true

module Crystalball
  class MapGenerator
    module Helpers
      # Helper module to filter file paths
      module PathFilter
        attr_reader :root_path
        attr_writer :exclude_sources

        def exclude_sources
          @exclude_sources || []
        end

        # @param [String] root_path - absolute path to root folder of repository
        def initialize(root_path = Dir.pwd)
          @root_path = root_path
        end

        # @param [Array<String>] paths
        # @return relatve paths inside root_path only
        def filter(paths)
          paths
            .select { |file_name| file_name.start_with?(root_path) }
            .map { |file_name| file_name.sub("#{root_path}/", '') }
            .reject { |file_name| exclude_sources.any? do |pattern| pattern.match?(file_name) end }

        end
      end
    end
  end
end
