# frozen_string_literal: true

require 'pathname'

module Crystalball
  module RSpec
    # Class for building a prediction for RSpec runner.
    # Accepts configuration hash and builds a prediction according to configuration.
    class PredictionBuilder
      # Class for storing local prediction configuration
      class Configuration
        def initialize(config = {})
          @values = {
            'map_path' => 'tmp/execution_maps',
            'map_expiration_period' => 86_400,
            'repo_path' => Dir.pwd,
            'predictor_class_name' => 'Crystalball::Predictor',
            'requires' => [],
            'diff_from' => 'HEAD',
            'diff_to' => nil
          }.merge(config)
        end

        def to_h
          dynamic_values = {}
          (private_methods - Object.private_instance_methods - %i[run_requires values]).each do |method|
            dynamic_values[method.to_s] = send(method)
          end

          values.merge(dynamic_values)
        end

        def [](key)
          respond_to?(key, true) ? send(key) : values[key]
        end

        private

        def predictor_class
          @predictor_class ||= begin
            run_requires

            Object.const_get(self['predictor_class_name'])
          end
        end

        def map_path
          @map_path ||= Pathname.new(values['map_path'])
        end

        def repo_path
          @repo_path ||= Pathname.new(values['repo_path'])
        end

        attr_reader :values

        def run_requires
          self['requires'].each { |f| require f }
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
        return false if config['map_expiration_period'] <= 0

        map_commit = repo.gcommit(map.commit) || raise("Cant find map commit info #{map.commit}")

        map_commit.date < Time.now - config['map_expiration_period']
      end

      def map
        @map ||= Crystalball::MapStorage::YAMLStorage.load(config['map_path'])
      end

      private

      def repo
        @repo ||= Crystalball::GitRepo.open(config['repo_path'])
      end

      def base_predictor
        @base_predictor ||= config['predictor_class'].new(map, repo, from: config['diff_from'], to: config['diff_to'])
      end
    end
  end
end
