# frozen_string_literal: true

module Crystalball
  class Predictor
    # Used with `predictor.use Crystalball::Predictor::ModifiedExecutionPaths.new`. When used will check the map which
    # specs depend on which files and will return only those specs which depend on files modified since last time map
    # was generated.
    class ModifiedExecutionPaths
      # @param [Crystalball::SourceDiff] diff - the diff from which to predict
      #   which specs should run
      # @param [Crystalball::CaseMap] map - the map with the relations of
      #   examples and affected files
      # @return [Array<String>] the spec paths associated with the changes
      def call(diff, map)
        map.cases.map do |uid, case_map|
          uid if diff.any? { |file| case_map.include?(file.relative_path) }
        end.compact
      end
    end
  end
end
