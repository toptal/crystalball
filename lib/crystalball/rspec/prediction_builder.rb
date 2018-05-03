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
        return false if config['map_expiration_period'] <= 0

        map_commit = repo.gcommit!(execution_map.commit)

        map_commit ||= repo.fetch && repo.gcommit!(execution_map.commit)

        raise("Cant find map commit info #{execution_map.commit}") unless map_commit

        map_commit.date < Time.now - config['map_expiration_period']
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
