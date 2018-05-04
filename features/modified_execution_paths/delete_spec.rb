# frozen_string_literal: true

require_relative '../feature_helper'

describe 'Deleting source file' do
  include_context 'simple git repository'
  include_context 'class1 examples'
  include_context 'base forecast'

  let(:strategies) do
    [Crystalball::Predictor::ModifiedExecutionPaths.new]
  end

  it 'adds mapped examples to a prediction list' do
    delete class1_path

    expect(forecast).to include(*class1_examples)
  end
end
