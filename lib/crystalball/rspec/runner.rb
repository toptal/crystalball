# frozen_string_literal: true

require 'rspec/core'
require 'crystalball/rspec/prediction_builder'
require 'crystalball/rspec/examples_pruner'
require 'crystalball/rspec/filtering'

module Crystalball
  module RSpec
    # Our custom RSpec runner to run predictions
    class Runner < ::RSpec::Core::Runner
      class << self
        def run(args, err = $stderr, out = $stdout)
          return config['runner_class'].run(args, err, out) unless config['runner_class'] == self

          ::RSpec.configure do |c|
            c.silence_filter_announcements = true
          end

          out.puts "Crystalball starts to glow..."
          prediction = build_prediction(out)

          out.puts "Prediction: #{prediction.first(5).join(' ')}#{'...' if prediction.size > 5}"
          out.puts "Starting RSpec."

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
                           YAML.safe_load(config_file.read)
                         else
                           {}
                         end

            Configuration.new(config_src)
          end
        end

        protected

        def load_execution_map
          check_map($stdout)
          prediction_builder.execution_map
        end

        private

        attr_writer :config, :prediction_builder

        def config_file
          file = Pathname.new(ENV.fetch('CRYSTALBALL_CONFIG', 'crystalball.yml'))
          file = Pathname.new('config/crystalball.yml') unless file.exist?
          file.exist? ? file : nil
        end

        def build_prediction(out)
          check_map(out)
          # Actual examples size is not less than prediction size.
          prune_prediction_to_limit(prediction_builder.prediction.sort_by(&:length), out)
        end

        def prune_prediction_to_limit(prediction, out)
          limit = config['examples_limit'].to_i

          return prediction if !limit.positive? || prediction.size <= limit

          out.puts "Prediction size #{prediction.size} is over the limit (#{limit})"
          out.puts "Prediction is pruned to fit the limit!"

          prediction.first(limit)
        end

        def check_map(out)
          out.puts 'Maps are outdated!' if prediction_builder.expired_map?
        end
      end

      def run(err, out)
        setup(err, out)
        run_specs(prediction_example_groups(out)).tap do
          persist_example_statuses
        end
      end

      def prediction_example_groups(out)
        limit = self.class.config['examples_limit'].to_i

        pruner = ExamplesPruner.new(@world, to: limit)

        return pruner.world_groups if !limit.positive? || @world.example_count(pruner.world_groups) <= limit

        out.puts "Prediction examples size #{@world.example_count(pruner.world_groups)} is over the limit (#{limit})"
        out.puts "Prediction is pruned to fit the limit!"

        pruner.pruned_groups
      end

      def setup(err, out)
        configure(err, out)
        @configuration.load_spec_files

        # Since prediction compacting is disabled we need to remove filtering
        # in cases like './spec/foo.rb ./spec/foo.rb[1:1:2]'
        remove_unnecessary_filters(@options.options[:files_or_directories_to_run])

        @world.announce_filters
      end

      def configure(err, out)
        @configuration.error_stream = err
        @configuration.output_stream = out if @configuration.output_stream == $stdout
        @options.configure(@configuration)
      end

      private

      def remove_unnecessary_filters(files_or_directories)
        Filtering.remove_unnecessary_filters(@configuration, files_or_directories)
      end
    end
  end
end

require 'crystalball/rspec/runner/configuration'
