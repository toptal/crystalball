# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator::DescribedClassStrategy do
  subject(:strategy) { described_class.new(execution_detector: execution_detector) }

  let(:execution_detector) { instance_double('Crystalball::MapGenerator::ObjectSourcesDetector') }

  include_examples 'base strategy'

  describe '#call' do
    subject { strategy.call(example_group_map, example) {} }

    let(:example_group_map) { [] }
    let(:objects) { [Dummy] }
    let(:example) { double(metadata: {described_class: Dummy}) }

    before do
      stub_const('Dummy', Class.new)
      allow(execution_detector).to receive(:detect).with(objects) { [1, 2, 3] }
    end

    it 'yields example_group_map to a block' do
      expect do |b|
        strategy.call(example_group_map, example, &b)
      end.to yield_with_args(example_group_map, example)
    end

    it 'pushes used files detected by detector to example group map' do
      expect do
        subject
      end.to change { example_group_map }.to [1, 2, 3]
    end
  end
end
