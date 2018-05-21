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
        base_predictor.prediction
      end

      def expired_map?
        return false if config['map_expiration_period'] <= 0

        map_commit = repo.gcommit!(map.commit)

        map_commit ||= repo.fetch && repo.gcommit!(map.commit)

        raise("Cant find map commit info #{map.commit}") unless map_commit

        map_commit.date < Time.now - config['map_expiration_period']
      end

      def map
        @map ||= Crystalball::MapStorage::YAMLStorage.load(config['map_path'])
      end

      def repo
        @repo ||= Crystalball::GitRepo.open(config['repo_path'])
      end

      private

      def base_predictor
        @base_predictor ||= config['predictor_class'].new(map, repo, from: config['diff_from'], to: config['diff_to'])
      end
    end
  end
end
