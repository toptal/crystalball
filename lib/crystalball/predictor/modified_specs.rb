# frozen_string_literal: true

module Crystalball
  class Predictor
    # Used with `predictor.use Crystalball::Predictor::ModifiedSpecs.new`. Will find files that match spec regexp and
    # return all new or modified files. You can specify spec regexp using first parameter to `#initialize`.
    class ModifiedSpecs
      def initialize(spec_pattern = %r{\Aspec/.*_spec\.rb\z})
        @spec_pattern = spec_pattern
      end

      def call(diff, _)
        diff.reject(&:deleted?).map(&:new_relative_path).grep(spec_pattern)
      end

      private

      attr_reader :spec_pattern
    end
  end
end
