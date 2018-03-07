# frozen_string_literal: true

module Crystalball
  class Predictor
    # Used with `predictor.use Crystalball::Predictor::AssociatedSpecs.new(from: %r{models/(.*).rb}, to: "./spec/models/%s_spec.rb")`.
    # When used will look for files matched to `from` regex and use captures to fill `to` string to
    # get paths of proper specs
    class AssociatedSpecs
      # @param [Regexp] from - regular expression to match specific files and get proper captures
      # @param [String] to - string in sprintf format to get proper files using captures of regexp
      def initialize(from:, to:)
        @from = from
        @to = to
      end

      def call(diff, _)
        diff.map(&:relative_path).grep(from)
            .map { |source_file_path| to % captures(source_file_path) }
      end

      private

      attr_reader :from, :to

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
