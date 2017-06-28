require 'spec_helper'
require 'crystalball/map_generator'

class FakeExample
  def initialize(example_uid, &block)
    @example_uid  = example_uid
    @run_code = block
  end
  def run
    @run_code.call
  end
  def location_rerun_argument
    @example_uid
  end
end

describe Crystalball::MapGenerator do
  let(:example_path) { File.expand_path("../../../example", __FILE__) }
  let(:example_uid)  { 'my_test1_run' }
  let(:example_file) { 'my_test1.rb' }
  let(:example) do
    FakeExample.new(example_uid) {
      require File.join(example_path, example_file)
      MyTest1.test0
    }
  end
  let(:output)       { StringIO.new }
  let(:target_file)  { 'execution_map.yml' }

  subject { described_class.new(described_class.default_config) }

  before {
    allow(Dir).to  receive(:pwd).and_return(example_path)
    allow(File).to receive(:open).with(target_file, 'a').and_yield(output)
  }

  it 'should generate and diff' do
    subject.start!
    subject.refresh_for_case(example)
    subject.finalize!
    expect(output.string).to eq("#{example_uid}:\n- #{example_file}\n")
  end
end
