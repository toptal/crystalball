# frozen_string_literal: true

# Just a simple predictor to use it with bin/crystalball
class StandardPredictor < Crystalball::Predictor
  def initialize(*_)
    super
    use Crystalball::Predictor::ModifiedExecutionPaths.new
  end
end
