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
    change schema_path, File.read(fixtures_path.join('schema', 'model_table_changed.rb'))

    expect(forecast).to include(*model1_examples)
    expect(forecast).not_to include('./spec/models/model2_spec.rb[1:1:1]')
  end

  it 'writes a warning for a table with no model files' do
    change schema_path, File.read(fixtures_path.join('schema', 'relation_table_changed.rb'))

    expect(STDOUT).to receive(:puts).with(/WARNING: there are no model files for changed table `model1s_model2s`/)
    expect(forecast).to be_empty
  end
end
