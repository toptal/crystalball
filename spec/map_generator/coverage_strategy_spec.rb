# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator::CoverageStrategy do
  subject { described_class.new(execution_detector) }
  let(:execution_detector) { instance_double('Crystalball::MapGenerator::CoverageStrategy::ExecutionDetector') }

  include_examples 'base strategy'

  describe '#after_register' do
    it 'starts coverage' do
      expect(Coverage).to receive(:start)
      subject.after_register
    end
  end

  describe '#call' do
    let(:case_map) { instance_double('Crystalball::CaseMap', push: nil) }
    before do
      before = double
      after = double
      allow(Coverage).to receive(:peek_result).and_return(before, after)
      example_map = [1, 2, 3]
      allow(execution_detector).to receive(:detect).with(before, after).and_return(example_map)
    end

    it 'pushes affected files detected by detector to case map' do
      expect(case_map).to receive(:push).with(1, 2, 3, strategy: 'coverage_strategy')
      subject.call(case_map, 'example') {}
    end

    it 'yields case_map to a block' do
      expect do |b|
        subject.call(case_map, 'example', &b)
      end.to yield_with_args(case_map)
    end
  end
end
