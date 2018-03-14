# frozen_string_literal: true

module Crystalball
  class Predictor
    # Used with `predictor.use Crystalball::Predictor::ModifiedSpecs.new`. Will find files that match spec regexp and
    # return all new or modified files. You can specify spec regexp using first parameter to `#initialize`.
    class ModifiedSpecs
      # @param [Regexp] spec_pattern - regexp to filter specs files
      def initialize(spec_pattern = %r{spec/.*_spec\.rb\z})
        @spec_pattern = spec_pattern
      end

      # This strategy does not depend on a previously generated case map.
      # It uses the spec pattern to determine which specs should run.
      # @param [Crystalball::SourceDiff] diff - the diff from which to predict
      #   which specs should run
      # @return [Array<String>] the spec paths associated with the changes
      def call(diff, _)
        diff.reject(&:deleted?).map(&:new_relative_path).grep(spec_pattern)
      end

      private

      attr_reader :spec_pattern
    end
  end
end
