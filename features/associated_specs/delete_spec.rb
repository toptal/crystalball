# frozen_string_literal: true

require_relative '../feature_helper'

describe 'Deleting associated source file' do
  subject(:forecast) do
    Crystalball.foresee(workdir: root, map_path: root.join('execution_map.yml')) do |predictor|
      predictor.use Crystalball::Predictor::AssociatedSpecs.new from: %r{models/(?<file>.*).rb},
                                                                to: './spec/models/%<file>s_spec.rb'
    end
  end
  include_context 'simple git repository'

  it 'adds matched spec to a prediction list' do
    delete model1_path

    is_expected.to match_array(%w[./spec/models/model1_spec.rb])
  end
end
