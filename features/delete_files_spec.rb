# frozen_string_literal: true

require_relative '../spec/spec_helper'

describe 'delete files' do
  subject(:forecast) do
    Crystalball.foresee(workdir: root, map_path: root.join('execution_map.yml')) do |predictor|
      predictor.use Crystalball::Predictor::ModifiedExecutionPaths.new
    end
  end
  include_context 'simple git repository'

  it 'generates map if Class1 is deleted' do
    git.lib.remove class1_path

    is_expected.to include(*%w[
                                 ./spec/class1_spec.rb[1:1:1]
                                 ./spec/class1_spec.rb[1:1:2:1]
                                 ./spec/class1_spec.rb[1:1:3:1]
                                 ./spec/class1_spec.rb[1:1:4:1]
                                 ./spec/class1_spec.rb[1:2:1]
                                 ./spec/class1_spec.rb[1:3:1]
                                 ./spec/file_spec.rb[1:1]
                               ])
  end

  it 'generates map if Module1 is deleted' do
    git.lib.remove module1_path

    is_expected.to include(*%w[
                                 ./spec/class1_spec.rb[1:1:1]
                                 ./spec/class1_spec.rb[1:1:2:1]
                                 ./spec/class1_spec.rb[1:1:3:1]
                                 ./spec/class1_spec.rb[1:1:4:1]
                                 ./spec/class1_spec.rb[1:2:1]
                                 ./spec/class2_spec.rb[1:1:1]
                                 ./spec/class2_spec.rb[1:1:2:1]
                                 ./spec/class2_spec.rb[1:1:3:1]
                                 ./spec/class2_spec.rb[1:1:4:1]
                                 ./spec/class2_spec.rb[1:2:1]
                               ])
  end
end
