# frozen_string_literal: true

require_relative '../feature_helper'

describe 'Moving spec file' do
  include_context 'simple git repository'
  include_context 'base forecast'

  let(:strategies) { [Crystalball::Predictor::ModifiedSpecs.new] }

  it 'adds it to a prediction list' do
    move(class1_spec_path)

    expect(forecast).to match_array(%w[./spec/moved_class1_spec.rb])
  end
end
