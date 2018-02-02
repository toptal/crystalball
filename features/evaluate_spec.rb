# frozen_string_literal: true

require_relative '../spec/spec_helper'
require_relative '../lib/crystalball/predictor_evaluator'

describe 'evaluate prediction' do
  subject(:evaluator) do
    Crystalball::PredictorEvaluator.new(predictor, actual_failures: actual_failures)
  end
  include_context 'simple git repository'

  let(:predictor) do
    Crystalball::Predictor.new(map, diff) do |predictor|
      predictor.use Crystalball::Predictor::AssociatedSpecs.new from: %r{models/(?<file>.*).rb},
                                                                to: './spec/models/%<file>s_spec.rb'
    end
  end

  let(:map) { Crystalball::MapStorage::YAMLStorage.load(root.join('execution_map.yml')) }
  let(:diff) { Crystalball::SourceDiff.new(git.diff) }

  let(:actual_failures) do
    %w[./spec/models/model1_spec.rb ./spec/class1_spec.rb]
  end

  before do
    model1_path.open('w') { |f| f.write <<~RUBY }
      class Model1
      end
    RUBY
  end

  it { expect(evaluator.predicted_failures).to eq %w[./spec/models/model1_spec.rb] }
  it { expect(evaluator.unpredicted_failures).to eq %w[./spec/class1_spec.rb] }
  it { expect(evaluator.diff_size).to eq 14 }
  it { expect(evaluator.prediction_to_diff_ratio).to eq 2.0 / 14.0 }
  it { expect(evaluator.prediction_scale).to eq 2.0 / 18.0 }
  it { expect(evaluator.prediction_rate).to eq 0.5 }
  it { expect(evaluator.prediction_size).to eq 2 }
  it { expect(evaluator.map_size).to eq 18 }
end
