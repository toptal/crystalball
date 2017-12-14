# frozen_string_literal: true

require_relative '../spec/spec_helper'

describe 'local diff' do
  subject(:forecast) { Crystalball.foresee(root, root.join('execution_map.yml')) }
  let(:simple_app_path) { Pathname(__dir__).join('fixtures', 'simple_app') }
  let(:tmp_path) { Pathname(__dir__).join('tmp') }
  let(:root) { tmp_path.join('simple_app') }
  let(:lib_path) { root.join('lib') }
  let(:class1_path) { lib_path.join('class1.rb') }
  let(:class2_path) { lib_path.join('class2.rb') }

  after do
    root.rmtree
  end

  before do
    tmp_path.mkpath
    FileUtils.cp_r(simple_app_path, tmp_path)

    git = Git.init(root.to_s)
    git.add(all: true)
    git.commit('First commit')

    system("cd #{root} && rspec spec") # Generate crystalball map
  end

  it 'generates map if Class1 is changed' do
    class1_path.open('w') { |f| f.write <<~RUBY }
      class Class1
      end
    RUBY

    is_expected.to eq(%w[./spec/file_spec.rb:6])
  end

  it 'generates map if Class2 is changed' do
    class2_path.open('a') { |f| f.write <<~RUBY }
      Class2.__send__(:attr_reader, :var)
    RUBY

    is_expected.to eq(%w[./spec/file_spec.rb:8])
  end
end
