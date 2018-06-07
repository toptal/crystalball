# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator::DescribedClassStrategy do
  subject(:strategy) { described_class.new(execution_detector: execution_detector) }

  let(:execution_detector) { instance_double('Crystalball::MapGenerator::ObjectSourcesDetector') }

  include_examples 'base strategy'

  describe '#call' do
    subject { strategy.call(case_map, example) {} }

    let(:case_map) { instance_double('Crystalball::CaseMap', push: nil) }
    let(:objects) { [Dummy] }
    let(:example) { double(metadata: {described_class: Dummy}) }

    before do
      stub_const('Dummy', Class.new)
      allow(execution_detector).to receive(:detect).with(objects) { [1, 2, 3] }
    end

    it 'yields case_map to a block' do
      expect do |b|
        strategy.call(case_map, example, &b)
      end.to yield_with_args(case_map)
    end

    it 'pushes affected files detected by detector to case map' do
      expect(case_map).to receive(:push).with(1, 2, 3, strategy: 'described_class_strategy')
      subject
    end
  end
end
