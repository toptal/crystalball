# frozen_string_literal: true

require 'crystalball/predictor/strategy'

module Crystalball
  class Predictor
    # This strategy is almost the same as associated_specs.rb, but the only difference is that the `to` parameter also accept regex.
    # Used with `predictor.use Crystalball::Predictor::FilenamePatternSpecs.new(from: %r{models/(.*).rb}, to: "./spec/models/%s_spec.rb")`.
    # When used will look for files matched to `from` regex and use captures to fill `to` regex to
    # get paths of proper specs
    class RegexSpecs
      include Strategy

      # @param [file glob] scope - to find all the spec files scope to work with
      # @param [Regexp] from - regular expression to match specific files and get proper captures
      # @param [Regexp] to - regex in sprintf format to get proper files using captures of regexp
      def initialize(scope:, from:, to:)
        @scope = scope
        @from = from
        @to = to
      end

      def call(diff, _map)
        super do
          regex_string = diff.map(&:relative_path).grep(from).map { |source_file_path| to % captures(source_file_path) }
          regex_string.flat_map { |regex| Dir[scope].grep(Regexp.new regex)}
        end
      end

      private

      attr_reader :scope, :from, :to

      def captures(file_path)
        match = file_path.match(from)
        if match.names.any?
          match.names.map(&:to_sym).zip(match.captures).to_h
        else
          match.captures
        end
      end
    end
  end
end
