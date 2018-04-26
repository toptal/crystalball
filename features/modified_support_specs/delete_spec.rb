# frozen_string_literal: true

require_relative '../feature_helper'

describe 'Deleting support spec file' do
  subject(:forecast) do
    Crystalball.foresee(workdir: root, map_path: root.join('execution_map.yml')) do |predictor|
      predictor.use Crystalball::Predictor::ModifiedSupportSpecs.new
    end
  end
  include_context 'simple git repository'

  it 'adds full spec to a prediction list' do
    git.lib.remove action_view_shared_context

    is_expected.to match_array([
                                 './spec/views/index.html.erb_spec.rb',
                                 './spec/views/show.html.erb_spec.rb'
                               ])
  end
end
