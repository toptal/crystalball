# frozen_string_literal: true

require 'spec_helper'
require 'crystalball/predictor_evaluator'

describe Crystalball::PredictorEvaluator do
  subject(:evaluator) { described_class.new(predictor, actual_failures: actual_failures) }
  let(:predictor) { instance_double('Crystalball::Predictor', prediction: prediction, diff: git_diff, map: map) }
  let(:map) { instance_double('Crystalball::ExecutionMap', cases: cases, size: cases.size) }
  let(:cases) { {'./file1.rb[1:1]' => [], './file2.rb[1:1]' => [], './file2[1:2]' => []} }
  let(:git_diff) { instance_double('Crystalball::SourceDiff', lines: 42) }
  let(:prediction) { Crystalball::Prediction.new(%w[./file1.rb[1:1] ./file2.rb[1:1]]) }
  let(:actual_failures) { %w[./file1.rb[1:1] ./file2.rb[1:2]] }

  describe '#predicted_failures' do
    subject { evaluator.predicted_failures }

    it 'returns all cases that present in actual failures and prediction' do
      is_expected.to eq %w[./file1.rb[1:1]]
    end

    context 'with prediction as full file' do
      let(:prediction) { %w[file2.rb] }

      it 'returns all cases matching that file' do
        is_expected.to eq %w[./file2.rb[1:2]]
      end
    end
  end

  describe '#unpredicted_failures' do
    subject { evaluator.unpredicted_failures }

    it 'returns all cases that are present in actual failures but absent in prediction' do
      is_expected.to eq %w[./file2.rb[1:2]]
    end
  end

  describe '#diff_size' do
    subject { evaluator.diff_size }

    it 'returns total number of lines changed' do
      is_expected.to eq 42
    end
  end

  describe '#prediction_to_diff_ratio' do
    subject { evaluator.prediction_to_diff_ratio }

    it { is_expected.to eq(2 / 42.0) }
  end

  describe '#prediction_scale' do
    subject { evaluator.prediction_scale }

    it { is_expected.to eq(2 / 3.0) }
  end

  describe '#prediction_rate' do
    subject { evaluator.prediction_rate }

    it { is_expected.to eq(1 / 2.0) }

    context 'when there is no actual failures' do
      let(:actual_failures) { [] }

      it { is_expected.to eq(1.0) }
    end
  end

  describe '#prediction_size' do
    subject { evaluator.prediction_size }

    it { is_expected.to eq 2 }

    context 'when prediction is a folder' do
      let(:prediction) { %w[./] }

      it { is_expected.to eq 3 }
    end
  end

  describe '#map_size' do
    subject { evaluator.map_size }

    it { is_expected.to eq 3 }
  end
end
