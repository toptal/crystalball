# frozen_string_literal: true

require_relative '../feature_helper'

describe 'Changing source file with a class method call' do
  include_context 'base forecast'
  include_context 'simple git repository'

  let(:strategies) { [Crystalball::Predictor::ModifiedExecutionPaths.new] }

  it 'adds class2 example when class1 changes' do
    change class1_path

    expect(forecast).to include(
      './spec/class2_spec.rb[1:4:1]'
    )
  end
end
