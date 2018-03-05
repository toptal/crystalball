# frozen_string_literal: true

require_relative '../feature_helper'

describe 'change files' do
  subject(:forecast) do
    Crystalball.foresee(workdir: root, map_path: root.join('execution_map.yml')) do |predictor|
      predictor.use Crystalball::Predictor::ModifiedExecutionPaths.new
    end
  end
  include_context 'simple git repository'

  it 'generates map if Class1 is changed' do
    change class1_path

    is_expected.to include(
      './spec/class1_spec.rb[1:1:1]',
      './spec/class1_spec.rb[1:1:2:1]',
      './spec/class1_spec.rb[1:1:3:1]',
      './spec/class1_spec.rb[1:1:4:1]',
      './spec/class1_spec.rb[1:2:1]',
      './spec/class1_spec.rb[1:3:1]',
      './spec/file_spec.rb[1:1]'
    )
  end

  it 'generates map if Class1 reopen is changed' do
    change class1_reopen_path

    is_expected.to include(
      './spec/class1_spec.rb[1:1:1]',
      './spec/class1_spec.rb[1:1:2:1]',
      './spec/class1_spec.rb[1:1:3:1]',
      './spec/class1_spec.rb[1:1:4:1]',
      './spec/class1_spec.rb[1:2:1]',
      './spec/class1_spec.rb[1:3:1]',
      './spec/file_spec.rb[1:1]'
    )
  end

  it 'generates map if Class2 is changed' do
    change class2_path

    is_expected.to include(
      './spec/class2_spec.rb[1:1:1]',
      './spec/class2_spec.rb[1:1:2:1]',
      './spec/class2_spec.rb[1:1:3:1]',
      './spec/class2_spec.rb[1:1:4:1]',
      './spec/class2_spec.rb[1:2:1]',
      './spec/class2_spec.rb[1:3:1]',
      './spec/file_spec.rb[1:2]'
    )
  end

  it 'generates map if Module1 is changed' do
    change module1_path

    is_expected.to include(
      './spec/class1_spec.rb[1:1:1]',
      './spec/class1_spec.rb[1:1:2:1]',
      './spec/class1_spec.rb[1:1:3:1]',
      './spec/class1_spec.rb[1:1:4:1]',
      './spec/class1_spec.rb[1:2:1]',
      './spec/class2_spec.rb[1:1:1]',
      './spec/class2_spec.rb[1:1:2:1]',
      './spec/class2_spec.rb[1:1:3:1]',
      './spec/class2_spec.rb[1:1:4:1]',
      './spec/class2_spec.rb[1:2:1]'
    )
  end

  it 'generates map if Module2 is changed' do
    change module2_path

    is_expected.to include(
      './spec/class2_spec.rb[1:1:1]',
      './spec/class2_spec.rb[1:1:2:1]',
      './spec/class2_spec.rb[1:1:3:1]',
      './spec/class2_spec.rb[1:1:4:1]',
      './spec/class2_spec.rb[1:2:1]'
    )
  end

  it 'generates map if Model1 is changed' do
    change model1_path

    is_expected.to match_array(%w[
                                 ./spec/models/model1_spec.rb[1:2:1]
                                 ./spec/views/index.html.erb_spec.rb[1:1]
                                 ./spec/views/index.html.erb_spec.rb[1:2]
                                 ./spec/views/index.html.erb_spec.rb[1:3]
                                 ./spec/views/show.html.erb_spec.rb[1:1]
                               ])
  end

  it 'generates map if _item partial is changed' do
    change item_view_path

    is_expected.to match_array(%w[
                                 ./spec/views/index.html.erb_spec.rb[1:1]
                                 ./spec/views/index.html.erb_spec.rb[1:2]
                                 ./spec/views/index.html.erb_spec.rb[1:3]
                                 ./spec/views/show.html.erb_spec.rb[1:1]
                               ])
  end
end
