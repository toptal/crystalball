# frozen_string_literal: true

require_relative '../feature_helper'

describe 'Deleting source file' do
  subject(:forecast) do
    Crystalball.foresee(workdir: root, map_path: root.join('execution_map.yml')) do |predictor|
      predictor.use Crystalball::Predictor::ModifiedExecutionPaths.new
    end
  end
  include_context 'simple git repository'
  include_context 'class1 examples'

  it 'adds mapped examples to a prediction list' do
    delete class1_path

    is_expected.to include(*class1_examples)
  end
end
