# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator::AllocatedObjectsStrategy do
  subject(:strategy) { described_class.new(execution_detector: execution_detector, object_tracker: object_tracker) }

  let(:execution_detector) { instance_double('Crystalball::MapGenerator::ExecutionDetector') }
  let(:object_tracker) { instance_double('Crystalball::MapGenerator::AllocatedObjectsStrategy::ObjectTracker') }

  include_examples 'base strategy'

  describe '#call' do
    subject { strategy.call(case_map) {} }

    let(:case_map) { [] }
    let(:objects) { [] }

    before do
      allow(object_tracker).to receive(:created_during) { objects }.and_yield
      allow(execution_detector).to receive(:detect).with(objects) { [1, 2, 3] }
    end

    it 'manages GC' do
      expect(GC).to receive(:start)
      expect(GC).to receive(:disable)
      expect(GC).to receive(:enable)
      subject
    end

    it 'yields case_map to a block' do
      expect do |b|
        strategy.call(case_map, &b)
      end.to yield_with_args(case_map)
    end

    it 'pushes affected files detected by detector to case map' do
      expect do
        subject
      end.to change { case_map }.to [1, 2, 3]
    end
  end
end
