# frozen_string_literal: true

require_relative '../feature_helper'

describe 'Changing source file in a branch' do
  include_context 'simple git repository'
  include_context 'class1 examples'
  include_context 'model1 examples'
  include_context 'base forecast'

  let(:strategies) do
    [Crystalball::Predictor::ModifiedExecutionPaths.new]
  end

  before do
    change(class1_path)
    git.add(class1_path.to_s)
    git.commit('Second commit')
    git.checkout('HEAD^')
    git.branch('test').checkout
    change(model1_path)
  end

  it 'adds mapped examples to a prediction list for model1 only' do
    expect(forecast).to match_array(model1_examples)
  end
end
