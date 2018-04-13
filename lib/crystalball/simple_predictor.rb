# frozen_string_literal: true

require 'crystalball/predictor'
require 'crystalball/predictor/modified_execution_paths'
require 'crystalball/predictor/modified_specs'

module Crystalball
  # Class to predict test failures with given execution map and sources diff
  class SimplePredictor < Predictor
    def initialize(*args, &block)
      super(*args) do |p|
        p.use Crystalball::Predictor::ModifiedExecutionPaths.new
        p.use Crystalball::Predictor::ModifiedSpecs.new
        block&.call(p)
      end
    end
  end
end
