# frozen_string_literal: true

require_relative '../feature_helper'
require_relative './shared_contexts/class1_examples'

describe 'change files' do
  subject(:forecast) do
    Crystalball.foresee(workdir: root, map_path: root.join('execution_map.yml')) do |predictor|
      predictor.use Crystalball::Predictor::ModifiedExecutionPaths.new
    end
  end
  include_context 'simple git repository'
  include_context 'class1 examples'

  it 'generates diff if changes of Class1 were committed' do
    change class1_path
    git.add class1_path.to_s
    git.commit 'Second commit'

    is_expected.to include(*class1_examples)
  end
end
