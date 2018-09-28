# frozen_string_literal: true

require 'pathname'

module Crystalball
  module RSpec
    # Class for building a prediction for RSpec runner.
    # Accepts configuration hash and builds a prediction according to configuration.
    class PredictionBuilder
      attr_reader :config

      def initialize(config = {})
        @config = config
      end

      def prediction
        predictor.prediction
      end

      def expired_map?
        expiration_period = config['map_expiration_period'].to_i
        return false unless expiration_period.positive?

        execution_map.timestamp.to_i <= Time.now.to_i - config['map_expiration_period']
      end

      def execution_map
        @execution_map ||= Crystalball::MapStorage::YAMLStorage.load(config['execution_map_path'])
      end

      def repo
        @repo ||= Crystalball::GitRepo.open(config['repo_path'])
      end

      private

      # This method should be overridden in ancestor. Example:
      #
      # def predictor
      #   super do |p|
      #     p.use Crystalball::Predictor::ModifiedExecutionPaths.new
      #     p.use Crystalball::Predictor::ModifiedSpecs.new
      #   end
      # end
      #
      def predictor(&block)
        raise NotImplementedError, 'Configure `prediction_builder_class_name` in `crystalball.yml` and override `predictor` method' unless block_given?

        @predictor ||= Crystalball::Predictor.new(execution_map, repo, from: config['diff_from'], to: config['diff_to'], &block)
      end
    end
  end
end
