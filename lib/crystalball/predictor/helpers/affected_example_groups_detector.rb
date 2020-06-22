# frozen_string_literal: true

module Crystalball
  class Predictor
    module Helpers
      # Helper module to fetch example groups affected by given list of changed files
      module AffectedExampleGroupsDetector
        # Fetch examples affected by given list of files
        # @param [Array<String>] files - list of files
        # @param [Crystalball::ExecutionMap] map - execution map with examples
        # @return [Array<String>] list of affected examples
        def detect_examples(files, map)
          map.affected_examples(files: files)
        end
      end
    end
  end
end
