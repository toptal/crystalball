# frozen_string_literal: true

require_relative '../spec/spec_helper'

describe 'rename specs' do
  subject(:forecast) do
    Crystalball.foresee(workdir: root, map_path: root.join('execution_map.yml')) do |predictor|
      predictor.use Crystalball::Predictor::ModifiedSpecs.new
    end
  end
  include_context 'simple git repository'

  it 'generates map if class1_spec file was renamed' do
    move_path = spec_path.join('my_class_spec.rb')
    git.lib.mv(class1_spec_path, move_path)

    is_expected.to match_array(%w[spec/my_class_spec.rb])
  end
end
