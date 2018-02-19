# frozen_string_literal: true

require_relative '../spec/spec_helper'

describe 'change files' do
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
    class2_path.open('a') { |f| f.write <<~RUBY }
      Class2.__send__(:attr_reader, :var)
    RUBY

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
    module1_path.open('w') { |f| f.write <<~RUBY }
      module Module1
      end
    RUBY

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

  it 'generated diff if changes were committed' do
    class1_path.open('w') { |f| f.write <<~RUBY }
      class Class1
      end
    RUBY
    git.add class1_path.to_s
    git.commit 'Second commit'

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
end
