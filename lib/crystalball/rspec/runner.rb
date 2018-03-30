# frozen_string_literal: true

require 'rspec/core'
require 'crystalball/rspec/prediction_builder'

module Crystalball
  module RSpec
    # Our custom RSpec runner to run predictions
    class Runner < ::RSpec::Core::Runner
      class << self
        def invoke(config)
          setup_prediction_builder(config)
          super()
        end

        def run(args, err = $stderr, out = $stdout)
          out.puts "Crystalball starts to glow..."
          super(args + build_prediction(out), err, out)
        end

        private

        attr_reader :prediction_builder

        def setup_prediction_builder(config)
          @prediction_builder = PredictionBuilder.new(config)
        end

        def build_prediction(out)
          prediction = prediction_builder.prediction.compact
          out.puts "Prediction: #{prediction.first(5).join(' ')}#{'...' if prediction.size > 5}"
          out.puts "Starting RSpec."
          prediction
        end
      end
    end
  end
end
