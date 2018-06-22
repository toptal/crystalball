# frozen_string_literal: true

require_relative 'feature_helper'
require_relative '../lib/crystalball/predictor_evaluator'

describe 'Prediction evaluation' do
  subject(:evaluator) do
    Crystalball::PredictorEvaluator.new(predictor, actual_failures: actual_failures)
  end
  include_context 'simple git repository'

  map_generator_config do
    <<~CONFIG
      Crystalball::MapGenerator.start! do |c|
        c.register Crystalball::MapGenerator::CoverageStrategy.new
      end
    CONFIG
  end

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
      diff_size: 10,
      prediction_to_diff_ratio: 4.0 / 10,
      prediction_scale: 4.0 / 31,
      prediction_rate: 0.5,
      prediction_size: 4,
      map_size: 31
    )
  end
end
