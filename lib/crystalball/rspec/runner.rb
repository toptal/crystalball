# frozen_string_literal: true

require 'rspec/core'
require 'crystalball/rspec/prediction_builder'
require 'crystalball/rspec/filtering'
require 'crystalball/rspec/prediction_pruning'

module Crystalball
  module RSpec
    # Our custom RSpec runner to run predictions
    class Runner < ::RSpec::Core::Runner
      include PredictionPruning

      class << self
        def run(args, err = $stderr, out = $stdout)
          return config['runner_class'].run(args, err, out) unless config['runner_class'] == self

          Crystalball.log :info, "Crystalball starts to glow..."
          prediction = build_prediction

          Crystalball.log :debug, "Prediction: #{prediction.first(5).join(' ')}#{'...' if prediction.size > 5}"
          Crystalball.log :info, "Starting RSpec."

          super(args + prediction, err, out)
        end

        def reset!
          self.prediction_builder = nil
          self.config = nil
        end

        def prepare
          config['runner_class'].load_execution_map
        end

        def prediction_builder
          @prediction_builder ||= config['prediction_builder_class'].new(config)
        end

        def config
          @config ||= begin
            config_src = if config_file
                           require 'yaml'
                           YAML.safe_load(config_file.read, permitted_classes: [Symbol])
                         else
                           {}
                         end

            Configuration.new(config_src)
          end
        end

        protected

        def load_execution_map
          check_map
          prediction_builder.execution_map
        end

        private

        attr_writer :config, :prediction_builder

        def config_file
          file = Pathname.new(ENV.fetch('CRYSTALBALL_CONFIG', 'crystalball.yml'))
          file = Pathname.new('config/crystalball.yml') unless file.exist?
          file.exist? ? file : nil
        end

        def build_prediction
          check_map
          prune_prediction_to_limit(prediction_builder.prediction.sort_by(&:length))
        end

        def check_map
          Crystalball.log :warn, 'Maps are outdated!' if prediction_builder.expired_map?
        end
      end

      def setup(err, out)
        configure(err, out)
        @configuration.load_spec_files

        Filtering.remove_unnecessary_filters(@configuration, @options.options[:files_or_directories_to_run])

        if reconfiguration_needed?
          Crystalball.log :warn, "Prediction examples size #{@world.example_count} is over the limit (#{examples_limit})"
          Crystalball.log :warn, "Prediction is pruned to fit the limit!"

          reconfigure_to_limit
          @configuration.load_spec_files
        end

        @world.announce_filters
      end

      # Backward compatibility for RSpec < 3.7
      def configure(err, out)
        @configuration.error_stream = err
        @configuration.output_stream = out if @configuration.output_stream == $stdout
        @options.configure(@configuration)
      end
    end
  end
end

require 'crystalball/rspec/runner/configuration'
