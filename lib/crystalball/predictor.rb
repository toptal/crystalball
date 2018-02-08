# frozen_string_literal: true

module Crystalball
  # Class to predict test failures with given execution map and sources diff
  class Predictor
    attr_reader :map, :diff, :predictors

    # @param [Crystalball::ExecutionMap] map execution map
    # @param [Crystalball::GitRepo] repo to build execution list on
    # @param [String] from starting commit for diff. Default: HEAD
    # @param [String] to ending commit for diff. Default: nil
    def initialize(map, repo, from: 'HEAD', to: nil)
      @map = map
      @repo = repo
      @diff = repo.diff(from, to)
      @predictors = []
      yield self if block_given?
    end

    # Adds additional predictor to use
    #
    # @param [Object]
    def use(predictor)
      predictors << predictor
    end

    # TODO: check if it would be better to call predictors with one case instead of passing the whole map.
    # @return [Array<String>] list of examples which may fail
    def cases
      # TODO: minimize cases? like [./some/spec1, ./some/spec2, ./some/] -> [./some/]
      predictors
        .flat_map { |predictor| predictor.call(diff, map) }
        .compact
        .select { |example| example_to_file_path(example).exist? }
        .uniq
    end

    private

    attr_reader :repo

    def example_to_file_path(example)
      repo.repo_path.join(example.split('[').first).expand_path
    end
  end
end
