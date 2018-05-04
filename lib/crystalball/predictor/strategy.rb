# frozen_string_literal: true

require 'crystalball/predictor/helpers/path_formatter'

module Crystalball
  class Predictor
    # Base module to include in any strategy. Provides output formatting similar to RSpec
    module Strategy
      include Helpers::PathFormatter

      def call(*)
        format_paths(yield)
      end
    end
  end
end
