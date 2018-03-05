# frozen_string_literal: true

require_relative '../feature_helper'
require_relative './shared_contexts/class1_examples'

describe 'move files' do
  subject(:forecast) do
    Crystalball.foresee(workdir: root, map_path: root.join('execution_map.yml')) do |predictor|
      predictor.use Crystalball::Predictor::ModifiedExecutionPaths.new
    end
  end
  include_context 'simple git repository'
  include_context 'class1 examples'

  it 'generates map if Class1 file was moved' do
    move class1_path

    is_expected.to include(*class1_examples)
  end
end
