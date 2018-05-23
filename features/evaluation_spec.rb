# frozen_string_literal: true

require_relative 'feature_helper'
require_relative '../lib/crystalball/predictor_evaluator'

describe 'Prediction evaluation' do
  subject(:evaluator) do
    Crystalball::PredictorEvaluator.new(predictor, actual_failures: actual_failures)
  end
  include_context 'simple git repository'

  let(:predictor) do
    Crystalball::Predictor.new(map, Crystalball::GitRepo.open(git.dir.path)) do |predictor|
      predictor.use Crystalball::Predictor::AssociatedSpecs.new from: %r{models/(?<file>.*).rb},
                                                                to: './spec/models/%<file>s_spec.rb'
    end
  end

  let(:map) { Crystalball::MapStorage::YAMLStorage.load(root.join('execution_map.yml')) }

  let(:actual_failures) do
    %w[./spec/models/model1_spec.rb ./spec/class1_spec.rb]
  end

  before do
    model1_path.open('w') { |f| f.write <<~RUBY }
      class Model1
      end
    RUBY
  end

  it 'generates proper stats' do
    expect(evaluator).to have_attributes(
      predicted_failures: %w[./spec/models/model1_spec.rb],
      unpredicted_failures: %w[./spec/class1_spec.rb],
      diff_size: 14,
      prediction_to_diff_ratio: 2.0 / 14,
      prediction_scale: 2.0 / 25,
      prediction_rate: 0.5,
      prediction_size: 2,
      map_size: 25
    )
  end
end
