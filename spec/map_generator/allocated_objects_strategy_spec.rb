# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator::AllocatedObjectsStrategy do
  subject(:strategy) { described_class.new(execution_detector: execution_detector, object_lister: object_lister, definition_tracer: definition_tracer, hierarchy_lister: hierarchy_lister) }

  let(:execution_detector) { instance_double('Crystalball::MapGenerator::ExecutionDetector') }
  let(:object_lister) { instance_double('Crystalball::MapGenerator::AllocatedObjectsStrategy::ObjectLister') }
  let(:definition_tracer) { instance_double('Crystalball::MapGenerator::AllocatedObjectsStrategy::DefinitionTracer') }
  let(:hierarchy_lister) { instance_double('Crystalball::MapGenerator::AllocatedObjectsStrategy::HierarchyLister') }

  include_examples 'base strategy'

  describe '#after_register' do
    subject { strategy.after_register }

    it 'starts DefinitionTracer' do
      expect(definition_tracer).to receive(:start)
      subject
    end
  end

  describe '#before_finalize' do
    subject { strategy.before_finalize }

    it 'stops DefinitionTracer ' do
      expect(definition_tracer).to receive(:stop)
      subject
    end
  end

  describe '#call' do
    subject { strategy.call(case_map) {} }

    let(:case_map) { [] }
    let(:objects) { [] }
    let(:files) { [] }

    before do
      allow(object_lister).to receive(:created_during) { objects }.and_yield
      allow(execution_detector).to receive(:detect).with(files) { [1, 2, 3] }
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

    context 'with objects' do
      let(:files) { ['lib/dummy.rb'] }
      let(:objects) { [double(class: Dummy)] }

      before do
        stub_const('Dummy', Class.new)
        allow(definition_tracer).to receive(:constants_definition_paths) { {'Dummy' => 'lib/dummy.rb'} }
        allow(hierarchy_lister).to receive(:ancestors_for).with(Dummy) { [Dummy] }
      end

      it 'pushes affected files detected by detector to case map' do
        expect do
          subject
        end.to change { case_map }.to [1, 2, 3]
      end
    end
  end
end
