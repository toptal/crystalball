# frozen_string_literal: true

require 'rspec/core'
require 'crystalball/rspec/prediction_builder'
require 'active_support/core_ext/class/attribute'

module Crystalball
  module RSpec
    # Our custom RSpec runner to run predictions
    class Runner < ::RSpec::Core::Runner
      class_attribute :prediction_builder, :config

      class << self
        def run(args, err = $stderr, out = $stdout)
          setup_prediction_builder
          out.puts "Crystalball starts to glow..."
          super(args + build_prediction(out), err, out)
        end

        def reset!
          self.prediction_builder = nil
          self.config = nil
        end

        def prepare
          load_map
        end

        private

        def setup_prediction_builder
          load_config
          self.prediction_builder ||= PredictionBuilder.new(config)
        end

        def load_config
          self.config ||= begin
            config_file = Pathname.new(ENV.fetch('CRYSTALBALL_CONFIG', 'crystalball.yml'))
            config_file = Pathname.new('config/crystalball.yml') unless config_file.exist?

            if config_file.exist?
              require 'yaml'
              YAML.safe_load(config_file.read)
            else
              {}
            end
          end
        end

        def load_map
          setup_prediction_builder
          prediction_builder.map
        end

        def build_prediction(out)
          check_map(out) unless ENV['CRYSTALBALL_SKIP_MAP_CHECK']
          prediction = prediction_builder.prediction.compact
          prediction = ['spec/lib/crystalball/map_downloader_spec.rb']
          out.puts "Prediction: #{prediction.first(5).join(' ')}#{'...' if prediction.size > 5}"
          out.puts "Starting RSpec."
          prediction
        end

        def check_map(out)
          out.puts 'Maps are outdated!' if prediction_builder.expired_map?
        end
      end

      def run_specs(example_groups)
        check_examples_limit(example_groups)
        super
      end

      def check_examples_limit(example_groups)
        limit = self.class.config.examples_limit
        return if ENV['CRYSTALBALL_SKIP_EXAMPLES_LIMIT'] || !limit.positive?

        examples_count = @world.example_count(example_groups)

        if examples_count > limit
          @configuration.output_stream.puts "Example group size (#{examples_count}) is over the limit (#{limit})"
          @configuration.output_stream.puts "Aborting spec run"
          exit
        end
      end
    end
  end
end
