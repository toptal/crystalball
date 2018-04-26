# frozen_string_literal: true

require 'crystalball/predictor/helpers/affected_examples_detector'

module Crystalball
  class Predictor
    # Used with `predictor.use Crystalball::Predictor::ModifiedExecutionPaths.new`. When used will check the map which
    # specs depend on which files and will return only those specs which depend on files modified since last time map
    # was generated.
    class ModifiedExecutionPaths
      include ::Crystalball::Predictor::Helpers::AffectedExamplesDetector

      # @param [Crystalball::SourceDiff] diff - the diff from which to predict
      #   which specs should run
      # @param [Crystalball::CaseMap] map - the map with the relations of
      #   examples and affected files
      # @return [Array<String>] the spec paths associated with the changes
      def call(diff, map)
        detect_examples(diff.map(&:relative_path), map)
      end
    end
  end
end
