# frozen_string_literal: true

require_relative '../feature_helper'

describe 'Changing and commiting a source file' do
  subject(:forecast) do
    Crystalball.foresee(workdir: root, map_path: root.join('execution_map.yml')) do |predictor|
      predictor.use Crystalball::Predictor::ModifiedExecutionPaths.new
    end
  end
  include_context 'simple git repository'
  include_context 'class1 examples'

  it 'adds mapped examples to a prediction list' do
    change class1_path
    git.add class1_path.to_s
    git.commit 'Second commit'

    is_expected.to include(*class1_examples)
  end
end
