# frozen_string_literal: true

require 'crystalball/rspec/prediction_pruning/examples_pruner'

module Crystalball
  module RSpec
    # Module contains logic related to examples_limit configuration option for our runner.
    module PredictionPruning
      def self.included(base)
        base.extend ClassMethods
      end

      # Class methods for prediction pruning logic
      module ClassMethods
        def examples_limit
          config['examples_limit'].to_i
        end

        private

        def prune_prediction_to_limit(prediction)
          return prediction if !examples_limit || examples_limit <= 0 || prediction.size <= examples_limit

          Crystalball.log :warn, "Prediction size #{prediction.size} is over the limit (#{examples_limit})"
          Crystalball.log :warn, "Prediction is pruned to fit the limit!"

          # Actual examples size is not less than prediction size.
          prediction.first(examples_limit)
        end
      end

      private

      def examples_limit
        self.class.examples_limit
      end

      def reconfiguration_needed?
        examples_limit > 0 && @world.example_count > examples_limit
      end

      def reconfigure_to_limit
        pruner = ExamplesPruner.new(@world, to: examples_limit)

        @options = ::RSpec::Core::ConfigurationOptions.new(pruner.pruned_set)
        @world.reset
        @world.filtered_examples.clear
        @world.instance_variable_get(:@example_group_counts_by_spec_file).clear
        @configuration.reset
        @configuration.reset_filters

        @options.configure(@configuration)
      end
    end
  end
end
