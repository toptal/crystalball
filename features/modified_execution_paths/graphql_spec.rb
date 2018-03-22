# frozen_string_literal: true

require_relative '../feature_helper'

describe 'Changing source file' do
  subject(:forecast) do
    Crystalball.foresee(workdir: root, map_path: root.join('execution_map.yml')) do |predictor|
      predictor.use Crystalball::Predictor::ModifiedExecutionPaths.new
    end
  end
  include_context 'simple git repository'

  let(:type1_path) { lib_path.join('graphql_type1.rb') }
  let(:type2_path) { lib_path.join('graphql_type2.rb') }
  let(:query_type1_path) { lib_path.join('query_type1.rb') }

  it 'adds schema spec to the map when type changes' do
    change type1_path

    is_expected.to include(
      './spec/graphql_schema1_spec.rb[1:1:2]'
    )
  end

  it 'adds schema spec to the map when root type changes' do
    change query_type1_path

    is_expected.to include(
      './spec/graphql_schema1_spec.rb[1:1:2]'
    )
  end

  it 'does not add unrelated schema to map' do
    change type2_path

    is_expected.not_to include(
      './spec/graphql_schema1_spec.rb[1:1:2]'
    )

    is_expected.to include(
      './spec/graphql_schema2_spec.rb[1:1:2]'
    )
  end
end
