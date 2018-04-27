# frozen_string_literal: true

require_relative '../feature_helper'

describe 'Changing schema file' do
  subject(:forecast) do
    Crystalball.foresee(workdir: root, map_path: root.join('execution_map.yml')) do |predictor|
      predictor.use Crystalball::Rails::Predictor::ModifiedSchema.new(tables_map_path: root.join('tables_map.yml'))
    end
  end
  include_context 'simple git repository'
  include_context 'model1 examples'

  it 'adds mapped examples to a prediction list' do
    change schema_path

    is_expected.to include(*model1_examples)
  end
end
