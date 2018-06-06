# frozen_string_literal: true

require_relative 'feature_helper'

describe 'RSpec runner' do
  subject(:execute_runner) do
    Dir.chdir(root) { `bundle exec crystalball 2>&1`.strip }
  end
  include_context 'simple git repository'
  let(:important_class_path) { root.join('lib/important_class.rb') }
  let(:other_important_class_path) { root.join('lib/other_important_class.rb') }

  it 'predicts examples' do
    change class1_path

    is_expected.to match(%r{Prediction:.*(spec/class1_spec.rb|spec/file_spec.rb)})
  end

  it 'checks limit' do
    change class1_path

    is_expected.to match(/Prediction size \d+ is over the limit \(1\)/)
      .and match(/Prediction is pruned to fit the limit!/)
      .and match(/\d+ examples?, 0 failures/)
  end

  context 'when file, spec id, and directory are predicted' do
    before do
      ENV['CRYSTALBALL_EXAMPLES_LIMIT'] = '0'
      ENV['CRYSTALBALL_PREDICTION_BUILDER_CLASS_NAME'] = 'PredictionBuilder'
      ENV['CRYSTALBALL_REQUIRES'] = './prediction_builder'
    end

    after do
      ENV.delete('CRYSTALBALL_EXAMPLES_LIMIT')
      ENV.delete('CRYSTALBALL_PREDICTION_BUILDER_CLASS_NAME')
      ENV.delete('CRYSTALBALL_REQUIRES')
    end

    it 'runs the whole file' do
      change other_important_class_path # Adds ./spec/class2_spec.rb
      change class1_path                # Adds ./spec/class2_spec.rb[1:1:1]

      is_expected.to match(/.another_field/) # ./spec/class2_spec.rb[1:2]
    end

    context 'when the files are contained in the directories' do
      it 'runs the whole directory' do
        change important_class_path            # Adds ./spec/important_dir/
        change class2_path, 'class Class2;end' # Adds ./spec/important_dir/important_spec.rb[1:2]

        is_expected.to match(/does very specific stuff/) # ./spec/important_dir/important_spec.rb[1:1]
      end
    end

    context 'when only parts of a file need to run' do
      it 'only runs those examples' do
        change class1_path, 'class Class1;end' # Adds ./spec/important_dir/important_spec.rb[1:3]
        change class2_path, 'class Class2;end' # Adds ./spec/important_dir/important_spec.rb[1:2]

        is_expected.not_to match(/does very specific stuff/) # ./spec/important_dir/important_spec.rb[1:1]
      end
    end
  end
end
