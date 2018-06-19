# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::ExecutionMap do
  subject { described_class.new }
  let(:used_files) { instance_double(Array) }
  let(:example_group_map) { instance_double(Crystalball::ExampleGroupMap, uid: 'file_spec.rb:1', used_files: used_files) }

  before { allow(used_files).to receive(:uniq) { used_files } }

  describe '#<<' do
    it 'adds case to data' do
      expect do
        subject << example_group_map
      end.to change { subject.cases }.to('file_spec.rb:1' => used_files)
    end
  end

  describe 'clear!' do
    it 'wipes out all cases' do
      subject << example_group_map
      expect do
        subject.clear!
      end.to change { subject.cases.size }.by(-1)
    end
  end
end
