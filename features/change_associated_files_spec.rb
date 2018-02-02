# frozen_string_literal: true

require_relative '../spec/spec_helper'

describe 'change associated files' do
  subject(:forecast) do
    Crystalball.foresee(workdir: root, map_path: root.join('execution_map.yml')) do |predictor|
      predictor.use Crystalball::Predictor::AssociatedSpecs.new from: %r{models/(?<file>.*).rb},
                                                                to: './spec/models/%<file>s_spec.rb'
    end
  end
  include_context 'simple git repository'

  it 'generates map if Model1 is changed' do
    model1_path.open('w') { |f| f.write <<~RUBY }
      class Model1
      end
    RUBY

    is_expected.to match_array(%w[
                                 ./spec/models/model1_spec.rb
                               ])
  end
end
