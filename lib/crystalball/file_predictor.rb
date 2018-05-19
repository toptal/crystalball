# frozen_string_literal: true

module Crystalball
  # Class to predict test failures with given execution map and sources diff
  class FilePredictor < Predictor
    # @param [Crystalball::ExecutionMap] map execution map
    def initialize(map, root=Dir.pwd)
      @map = map
      @root = Pathname(root)
      @prediction_strategies = []
      yield self if block_given?
    end

    # @param [String] file_path for which to fetch dependent specs
    # @return [Crystalball::Prediction] list of examples which may fail
    def prediction(file_paths)
      Prediction.new(filter(raw_prediction(file_paths)))
    end

    private

    attr_reader :root

    # TODO: check if it would be better to call predictors with one case instead of passing the whole map.
    def raw_prediction(file_paths)
      prediction_strategies.flat_map { |strategy| strategy.call(file_paths, map) }
    end

    def example_to_file_path(example)
      root.join(example.split('[').first).expand_path
    end
  end
end
