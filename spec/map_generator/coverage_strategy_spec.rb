# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator::CoverageStrategy do
  subject { described_class.new(execution_detector) }
  let(:execution_detector) { instance_double('Crystalball::MapGenerator::CoverageStrategy::ExecutionDetector') }

  include_examples 'base strategy'

  describe '#after_register' do
    context 'when Coverage is already running' do
      it 'does nothing' do
        allow(Coverage).to receive(:running?).and_return(true)
        expect(Coverage).not_to receive(:start)
        subject.after_register
      end
    end

    context 'when Coverage is not running' do
      it 'starts coverage' do
        allow(Coverage).to receive(:running?).and_return(false)
        expect(Coverage).to receive(:start)
        subject.after_register
      end
    end
  end

  describe '#call' do
    let(:example_group_map) { [] }
    before do
      before = double
      after = double
      allow(Coverage).to receive(:peek_result).and_return(before, after)
      example_map = [1, 2, 3]
      allow(execution_detector).to receive(:detect).with(before, after).and_return(example_map)
    end

    it 'pushes used files detected by detector to example group map' do
      expect do
        subject.call(example_group_map, 'example') {}
      end.to change { example_group_map }.to [1, 2, 3]
    end

    it 'yields example_group_map to a block' do
      expect do |b|
        subject.call(example_group_map, 'example', &b)
      end.to yield_with_args(example_group_map, 'example')
    end
  end
end
