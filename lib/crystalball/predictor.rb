# frozen_string_literal: true

module Crystalball
  # Class that predicts test failures with given execution map and sources diff
  class Predictor
    attr_reader :map, :diff, :predictors

    def initialize(map, source_diff)
      @map = map
      @diff = source_diff
      @predictors = []
      yield self if block_given?
    end

    def use(predictor)
      predictors << predictor
    end

    # TODO: check if it would be better to call predictors with one case instead of passing the whole map.
    def cases
      # TODO: minimize cases? like [./some/spec1, ./some/spec2, ./some/] -> [./some/]
      predictors
        .flat_map { |predictor| predictor.call(diff, map) }
        .compact
        .select { |example| File.exist?(example_to_file_path(example)) }
        .uniq
    end

    private

    def example_to_file_path(example)
      root = diff.repository.dir.path
      File.join(root, example).split('[').first
    end
  end
end
