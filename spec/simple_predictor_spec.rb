# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::SimplePredictor do
  subject { described_class.new(Crystalball::ExecutionMap.new, repo) }
  let(:repo) { instance_double('Crystalball::GitRepo') }

  it { is_expected.to be_a Crystalball::Predictor }

  it 'has ModifiedSpecs strategy registered' do
    expect(subject.prediction_strategies).to include(kind_of(Crystalball::Predictor::ModifiedSpecs))
  end

  it 'has ModifiedExecutionPaths strategy registered' do
    expect(subject.prediction_strategies).to include(kind_of(Crystalball::Predictor::ModifiedExecutionPaths))
  end
end
