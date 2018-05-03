# frozen_string_literal: true

require_relative '../feature_helper'

describe 'Deleting associated source file' do
  include_context 'simple git repository'
  include_context 'base forecast'

  let(:strategies) do
    [
      Crystalball::Predictor::AssociatedSpecs.new(from: %r{models/(?<file>.*).rb},
                                                  to: 'spec/models/%<file>s_spec.rb')
    ]
  end

  it 'adds matched spec to a prediction list' do
    delete model1_path

    expect(forecast).to match_array(%w[./spec/models/model1_spec.rb])
  end
end
