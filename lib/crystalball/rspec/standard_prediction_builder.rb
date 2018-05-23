# frozen_string_literal: true

module Crystalball
  module RSpec
    # Simple version of predictor
    class StandardPredictionBuilder < PredictionBuilder
      private

      def predictor
        super do |p|
          p.use Crystalball::Predictor::ModifiedExecutionPaths.new
          p.use Crystalball::Predictor::ModifiedSpecs.new
        end
      end
    end
  end
end
