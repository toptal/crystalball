# frozen_string_literal: true

require_relative '../spec/spec_helper'

describe 'delete specs' do
  subject(:forecast) do
    Crystalball.foresee(workdir: root, map_path: root.join('execution_map.yml')) do |predictor|
      predictor.use Crystalball::Predictor::ModifiedSpecs.new
    end
  end
  include_context 'simple git repository'

  it 'generates map if Class1 spec is deleted' do
    git.lib.remove class1_spec_path

    is_expected.to match_array([])
  end
end
