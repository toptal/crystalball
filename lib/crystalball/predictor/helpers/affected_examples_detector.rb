# frozen_string_literal: true

module Crystalball
  class Predictor
    module Helpers
      # Helper module to fetch examples affected by given list of changed files
      module AffectedExamplesDetector
        # Fetch examples affected by given list of files
        # @param [Array<String>] files - list of files
        # @param [Crystalball::ExecutionMap] map - execution map with examples
        # @return [Array<String>] list of affected examples
        def detect_examples(files, map)
          map.cases.map do |uid, case_map|
            uid if files.any? do |file|
              if case_map.is_a?(Array) # support old version of map. TODO: remove it.
                case_map.include?(file)
              else
                case_map.values.flatten.include?(file)
              end
            end
          end.compact
        end
      end
    end
  end
end
