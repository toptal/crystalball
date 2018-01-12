# frozen_string_literal: true

require_relative '../spec/spec_helper'

describe 'local diff' do
  subject(:forecast) do
    Crystalball.foresee(workdir: root, map_path: root.join('execution_map.yml')) do |predictor|
      predictor.use Crystalball::Predictor::ModifiedExecutionPaths.new
    end
  end
  include_context 'simple git repository'

  it 'generates map if Class1 is changed' do
    class1_path.open('w') { |f| f.write <<~RUBY }
      class Class1
      end
    RUBY

    is_expected.to eq(['./spec/file_spec.rb[1:1]'])
  end

  it 'generates map if Class2 is changed' do
    class2_path.open('a') { |f| f.write <<~RUBY }
      Class2.__send__(:attr_reader, :var)
    RUBY

    is_expected.to eq(['./spec/file_spec.rb[1:2]'])
  end

  it 'generated diff if changes were committed' do
    class1_path.open('w') { |f| f.write <<~RUBY }
      class Class1
      end
    RUBY
    git.add class1_path.to_s
    git.commit 'Second commit'

    is_expected.to eq(['./spec/file_spec.rb[1:1]'])
  end
end
