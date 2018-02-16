# frozen_string_literal: true

module Crystalball
  class MapGenerator
    module Concerns
      module PathsFilter
        # Transforms absolute paths to relative. Exclude paths outside of root_path
        #
        # @param[Array<String>] list of paths to process
        # @return [Array<String>]
        def filter(paths)
          paths
            .select { |file_name| file_name.start_with?(root_path) }
            .map { |file_name| file_name.sub("#{root_path}/", '') }
        end
      end
    end
  end
end
