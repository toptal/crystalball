# frozen_string_literal: true

require 'crystalball/predictor/modified_execution_paths'
require 'crystalball/predictor/modified_specs'

module Crystalball
  # Class that predicts test failures with given execution map and sources diff
  class Predictor
    def initialize(map, source_diff)
      @map = map
      @diff = source_diff
      @predictors = []
    end

    def use(predictor)
      predictors << predictor
    end

    # TODO: check if it would be better to call predictors with one case instead of passing the whole map.
    def cases
      predictors.flat_map { |predictor| predictor.call(diff, map) }
    end

    private

    attr_reader :map, :diff, :predictors
  end
end
