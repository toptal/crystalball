# frozen_string_literal: true

require 'crystalball/predictor/modified_execution_paths'
require 'crystalball/predictor/modified_specs'

module Crystalball
  # Class that predicts test failures with given execution map and sources diff
  class PredictorEvaluator
    attr_reader :predictor, :actual_failures

    def initialize(predictor, actual_failures:)
      @predictor = predictor
      @actual_failures = actual_failures
    end

    def predicted_failures
      @predicted_failures ||= actual_failures & prediction
    end

    def unpredicted_failures
      actual_failures - predicted_failures
    end

    def diff_size
      predictor.diff.lines
    end

    private

    def prediction
      @prediction ||= predictor.cases

      raise 'Prediction is empty!' if @prediction.empty?

      @prediction
    end
  end
end
