# frozen_string_literal: true

require_relative '../feature_helper'

describe 'Changing schema file' do
  include_context 'simple git repository'
  include_context 'model1 examples'
  include_context 'base forecast'

  let(:strategies) do
    [Crystalball::Rails::Predictor::ModifiedSchema.new(tables_map_path: root.join('tables_map.yml'))]
  end

  it 'adds mapped examples to a prediction list' do
    change schema_path

    expect(forecast).to include(*model1_examples)
  end
end
