# frozen_string_literal: true

# Sample prediction builder
class PredictionBuilder < ::Crystalball::RSpec::PredictionBuilder
  private

  def predictor
    super do |p|
      p.use Crystalball::Predictor::ModifiedExecutionPaths.new
      p.use Crystalball::Predictor::ModifiedSpecs.new
      p.use ::Crystalball::Predictor::AssociatedSpecs
        .new(from: /(other_important_class)\.rb/, to: './spec/class2_spec.rb')
      p.use ::Crystalball::Predictor::AssociatedSpecs
        .new(from: /(important).*\.rb/, to: './spec/important_dir/')
    end
  end
end
