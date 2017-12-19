# frozen_string_literal: true

module Crystalball
  class Predictor
    # Used with `predictor.use Crystalball::Predictor::ModifiedExecutionPaths.new`. When used will check the map which
    # specs depend on which files and will return only those specs which depend on files modified since last time map
    # was generated.
    class ModifiedExecutionPaths
      def call(diff, map)
        map.cases.map do |case_uid, case_map|
          case_uid if diff.any? { |file| case_map.include?(file.relative_path) }
        end.compact
      end
    end
  end
end
