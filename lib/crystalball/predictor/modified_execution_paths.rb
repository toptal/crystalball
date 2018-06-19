# frozen_string_literal: true

require 'crystalball/predictor/strategy'
require 'crystalball/predictor/helpers/affected_example_groups_detector'

module Crystalball
  class Predictor
    # Used with `predictor.use Crystalball::Predictor::ModifiedExecutionPaths.new`. When used will check the map which
    # specs depend on which files and will return only those specs which depend on files modified since last time map
    # was generated.
    class ModifiedExecutionPaths
      include Helpers::AffectedExampleGroupsDetector
      include Strategy

      # @param [Crystalball::SourceDiff] diff - the diff from which to predict
      #   which specs should run
      # @param [Crystalball::ExampleGroupMap] map - the map with the relations of
      #   examples and used files
      # @return [Array<String>] the spec paths associated with the changes
      def call(diff, map)
        super do
          detect_examples(diff.map(&:relative_path), map)
        end
      end
    end
  end
end
