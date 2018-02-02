# frozen_string_literal: true

require_relative '../spec/spec_helper'

describe 'change views files' do
  subject(:forecast) do
    Crystalball.foresee(workdir: root, map_path: root.join('execution_map.yml')) do |predictor|
      predictor.use Crystalball::Predictor::ModifiedExecutionPaths.new
    end
  end
  include_context 'simple git repository'

  it 'generates map if Model1 is changed' do
    model1_path.open('w') { |f| f.write <<~RUBY }
      class Model1
      end
    RUBY

    is_expected.to match_array(%w[
                                 ./spec/models/model1_spec.rb[1:2:1]
                                 ./spec/views/index.html.erb_spec.rb[1:1]
                                 ./spec/views/index.html.erb_spec.rb[1:2]
                                 ./spec/views/index.html.erb_spec.rb[1:3]
                                 ./spec/views/show.html.erb_spec.rb[1:1]
                               ])
  end

  it 'generates map if _item partial is changed' do
    item_view_path.open('w') { |f| f.write('') }

    is_expected.to match_array(%w[
                                 ./spec/views/index.html.erb_spec.rb[1:1]
                                 ./spec/views/index.html.erb_spec.rb[1:2]
                                 ./spec/views/index.html.erb_spec.rb[1:3]
                                 ./spec/views/show.html.erb_spec.rb[1:1]
                               ])
  end
end
