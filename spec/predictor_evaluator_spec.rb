# frozen_string_literal: true

require 'spec_helper'
require 'crystalball/predictor_evaluator'

describe Crystalball::PredictorEvaluator do
  subject(:evaluator) { described_class.new(predictor, actual_failures: actual_failures) }
  let(:predictor) { instance_double('Crystalball::Predictor', cases: prediction, diff: git_diff) }
  let(:git_diff) { instance_double('Crystalball::SourceDiff', lines: 42) }
  let(:prediction) { %w[file1.rb[1:1] file2.rb[1:1]] }
  let(:actual_failures) { %w[file1.rb[1:1] file2.rb[1:2]] }

  describe '#predicted_failures' do
    it 'returns all cases that present in actual failures and prediction' do
      expect(evaluator.predicted_failures).to eq %w[file1.rb[1:1]]
    end
  end

  describe '#unpredicted_failures' do
    it 'returns all cases that are present in actual failures but absent in prediction' do
      expect(evaluator.unpredicted_failures).to eq %w[file2.rb[1:2]]
    end
  end

  describe '#diff_size' do
    it 'returns total number of lines changed' do
      expect(evaluator.diff_size).to eq 42
    end
  end
end
