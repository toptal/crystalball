# frozen_string_literal: true

require 'pathname'

module Crystalball
  module RSpec
    # Class for building a prediction for RSpec runner.
    # Accepts configuration hash and builds a prediction according to configuration.
    class PredictionBuilder
      # Class for storing local prediction configuration
      class Configuration
        attr_reader :map_path, :map_expiration_period, :repo_path, :predictor_class_name, :diff_from, :diff_to, :requires

        def initialize(config = {})
          @raw_config = config
          @map_path = Pathname(config.fetch('map_path', 'tmp/execution_maps'))
          @map_expiration_period = config.fetch('map_expiration_period', 86_400).to_i
          @repo_path = Pathname(config.fetch('repo_path', Dir.pwd))
          @predictor_class_name = config.fetch('predictor_class', 'Crystalball::Predictor')
          @requires = config.fetch('requires', [])
          @diff_from = config.fetch('diff_from', 'HEAD')
          @diff_to = config.fetch('diff_to', nil)
        end

        def predictor_class
          @predictor_class ||= begin
            run_requires

            Object.const_get(predictor_class_name)
          end
        end

        def method_missing(method, *_)
          raw_config[method.to_s] || super
        end

        def respond_to_missing?(method, *_)
          raw_config[method.to_s] || super
        end

        private

        attr_reader :raw_config

        def run_requires
          requires.each { |f| require f }
        end
      end

      attr_reader :config

      def initialize(configuration = {})
        @config = Configuration.new(configuration)
      end

      def prediction
        base_predictor.prediction
      end

      def expired_map?
        return false if config.map_expiration_period <= 0

        map_commit = repo.gcommit(map.commit) || raise("Cant find map commit info #{map.commit}")

        map_commit.date < Time.now - config.map_expiration_period
      end

      private

      def map
        @map ||= Crystalball::MapStorage::YAMLStorage.load(config.map_path)
      end

      def repo
        @repo ||= Crystalball::GitRepo.open(config.repo_path)
      end

      def base_predictor
        @base_predictor ||= config.predictor_class.new(map, repo, from: config.diff_from, to: config.diff_to)
      end
    end
  end
end
