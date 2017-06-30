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
  let(:target_file)  { 'execution_map.yml' }

  before do
    # disable flushing at_exit:
    allow_any_instance_of(Crystalball::MapGenerator::PersistedMap).to receive(:at_exit)
  end

  describe '#refresh_for_case' do
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

    subject { described_class.new(described_class.build_default_config(project_root: example_path, flush_threshold: 1)) }

    before do
      allow(File).to receive(:open).with(target_file, 'a').and_yield(output)
    end

    it 'should generate and diff' do
      subject.refresh_for_case(example)
      expect(output.string).to eq("#{example_uid}:\n- #{example_file}\n")
    end
  end

  describe '.build_default_config' do
    context 'default file name' do
      subject { described_class.build_default_config(flush_threshold: 1) }

      specify { expect(subject[:map].storage.path).to eq('execution_map.yml') }
    end

    context 'changed file name' do
      let(:target_file) { 'test.yml' }

      subject { described_class.build_default_config(yaml_file_name: target_file, flush_threshold: 1) }

      it 'allows configuring file name' do
        expect(subject[:map].storage.path).to eq(target_file)
      end
    end
  end
end
