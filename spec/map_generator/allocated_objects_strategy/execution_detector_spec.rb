# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator::AllocatedObjectsStrategy::ExecutionDetector do
  subject(:detector) { described_class.new(definition_tracer: definition_tracer, hierarchy_fetcher: hierarchy_fetcher) }

  let(:definition_tracer) { instance_double('Crystalball::MapGenerator::AllocatedObjectsStrategy::DefinitionTracer') }
  let(:hierarchy_fetcher) { instance_double('Crystalball::MapGenerator::AllocatedObjectsStrategy::HierarchyFetcher') }

  describe '#after_register' do
    subject { detector.after_register }

    it 'starts DefinitionTracer' do
      expect(definition_tracer).to receive(:start)
      subject
    end
  end

  describe '#before_finalize' do
    subject { detector.before_finalize }

    it 'stops DefinitionTracer ' do
      expect(definition_tracer).to receive(:stop)
      subject
    end
  end

  describe '#detect' do
    subject { detector.detect(objects) }

    let(:files) { ['lib/dummy.rb'] }
    let(:objects) { [double(class: Dummy)] }

    before do
      stub_const('Dummy', Class.new)
      allow(definition_tracer).to receive(:constants_definition_paths) { {Dummy => [1, 2, 3]} }
      allow(hierarchy_fetcher).to receive(:ancestors_for).with(Dummy) { [Dummy] }
      allow(detector).to receive(:filter).with([1, 2, 3]) { [1, 2] }
    end

    it 'returns filtered paths of objects definition' do
      is_expected.to eq [1, 2]
    end
  end
end
