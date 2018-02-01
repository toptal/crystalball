# frozen_string_literal: true

module Crystalball
  # Class that predicts test failures with given execution map and sources diff
  class PredictorEvaluator
    attr_reader :predictor, :actual_failures

    def initialize(predictor, actual_failures:)
      @predictor = predictor
      @actual_failures = actual_failures
    end

    def predicted_failures
      @predicted_failures ||= actual_failures.select do |failure|
        prediction.any? { |p| failure.include?(p) }
      end
    end

    def unpredicted_failures
      actual_failures - predicted_failures
    end

    def diff_size
      predictor.diff.lines
    end

    def prediction_to_diff_ratio
      prediction_size.to_f / diff_size
    end

    def prediction_scale
      prediction_size.to_f / map_size
    end

    def prediction_rate
      actual_failures.empty? ? 1.0 : predicted_failures.size.to_f / actual_failures.size
    end

    def prediction_size
      predictor.map.cases.keys.select { |example| prediction.any? { |p| example.include?(p) } }.size
    end

    def map_size
      predictor.map.size
    end

    private

    def prediction
      @prediction ||= predictor.cases
    end
  end
end
