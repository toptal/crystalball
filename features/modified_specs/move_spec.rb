# frozen_string_literal: true

require_relative '../feature_helper'

describe 'move specs' do
  subject(:forecast) do
    Crystalball.foresee(workdir: root, map_path: root.join('execution_map.yml')) do |predictor|
      predictor.use Crystalball::Predictor::ModifiedSpecs.new
    end
  end
  include_context 'simple git repository'

  it 'generates map if class1_spec file was moved' do
    move(class1_spec_path)

    is_expected.to match_array(%w[spec/moved_class1_spec.rb])
  end
end
