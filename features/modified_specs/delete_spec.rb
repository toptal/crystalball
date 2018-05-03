# frozen_string_literal: true

require_relative '../feature_helper'

describe 'Deleting spec file' do
  include_context 'simple git repository'
  include_context 'base forecast'

  let(:strategies) { [Crystalball::Predictor::ModifiedSpecs.new] }

  it 'does not add it to a prediction list' do
    delete class1_spec_path

    expect(forecast).to match_array([])
  end
end
