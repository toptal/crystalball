# frozen_string_literal: true

module Crystalball
  # Class to predict test failures with given execution map and sources diff
  class Predictor
    attr_reader :map, :from, :to, :prediction_strategies

    # @param [Crystalball::ExecutionMap] map execution map
    # @param [Crystalball::GitRepo] repo to build execution list on
    # @param [String] from starting commit for diff. Default: HEAD
    # @param [String] to ending commit for diff. Default: nil
    def initialize(map, repo, from: 'HEAD', to: nil)
      @map = map
      @repo = repo
      @from = from
      @to = to
      @prediction_strategies = []
      yield self if block_given?
    end

    # Adds additional predictor to use
    #
    # @param [#call] strategy - the strategy can be any object that responds to #call
    def use(strategy)
      prediction_strategies << strategy
    end

    # @return [Crystalball::Prediction] list of examples which may fail
    def prediction
      Prediction.new(filter(raw_prediction(diff)))
    end
    alias cases prediction

    def diff
      @diff ||= begin
                  ancestor = repo.merge_base(from, to || 'HEAD').sha
                  repo.diff(ancestor, to)
                end
    end

    private

    # TODO: check if it would be better to call predictors with one case instead of passing the whole map.
    def predict!(current_diff)
      prediction_strategies.flat_map { |strategy| strategy.call(current_diff, map) }
    end
    alias raw_prediction predict!

    attr_reader :repo

    def filter(raw_cases)
      raw_cases.compact.select { |example| example_to_file_path(example).exist? }.uniq
    end

    def example_to_file_path(example)
      repo.repo_path.join(example.split('[').first).expand_path
    end
  end
end
