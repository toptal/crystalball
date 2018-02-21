# frozen_string_literal: true

module Crystalball
  class MapGenerator
    module Helpers
      # Class for filtering files paths
      module PathFilter
        attr_reader :root_path

        # @param [String] absolute path to root folder of repository
        def initialize(root_path = Dir.pwd)
          @root_path = root_path
        end

        # @param Array[String] paths
        # @return relatve paths inside root_path only
        def filter(paths)
          paths
            .select { |file_name| file_name.start_with?(root_path) }
            .map { |file_name| file_name.sub("#{root_path}/", '') }
        end
      end
    end
  end
end
