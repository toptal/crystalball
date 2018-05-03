# frozen_string_literal: true

require_relative '../feature_helper'

describe 'Moving spec file' do
  subject(:forecast) do
    Crystalball.foresee(workdir: root, map_path: root.join('execution_map.yml')) do |predictor|
      predictor.use Crystalball::Predictor::ModifiedSpecs.new
    end
  end
  include_context 'simple git repository'

  it 'adds it to a prediction list' do
    move(class1_spec_path)

    is_expected.to match_array(%w[./spec/moved_class1_spec.rb])
  end
end
