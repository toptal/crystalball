# frozen_string_literal: true

require 'crystalball/predictor/strategy'
require 'crystalball/predictor/helpers/affected_examples_detector'

module Crystalball
  class Predictor
    # Used with `predictor.use Crystalball::Predictor::ModifiedSupportSpecs.new`. Will find files that match passed regexp and
    # return full spec files which uses matched support spec files. Perfectly works for shared_context and shared_examples.
    class ModifiedSupportSpecs
      include Strategy
      include Helpers::AffectedExamplesDetector

      # @param [Regexp] support_spec_pattern - regexp to filter support specs files
      def initialize(support_spec_pattern = %r{spec/support/.*\.rb\z})
        @support_spec_pattern = support_spec_pattern
      end

      # @param [Crystalball::SourceDiff] diff - the diff from which to predict
      #   which specs should run
      # @param [Crystalball::CaseMap] map - the map with the relations of
      #   examples and affected files
      # @return [Array<String>] the spec paths associated with the changes
      def call(diff, map)
        super do
          changed_support_files = diff.map(&:relative_path).grep(support_spec_pattern)

          examples = detect_examples(changed_support_files, map)

          examples.map { |e| e.to_s.split('[').first }.uniq
        end
      end

      private

      attr_reader :support_spec_pattern
    end
  end
end
