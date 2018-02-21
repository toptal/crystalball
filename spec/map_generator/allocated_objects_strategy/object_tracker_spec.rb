# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator::AllocatedObjectsStrategy::ObjectTracker do
  subject(:tracker) { described_class.new(ignored_types) }

  let(:ignored_types) { [] }
  let(:obj1) { double }
  let(:obj2) { double(class: Dummy) }

  before do
    stub_const('Dummy', Class.new)
    allow(ObjectSpace).to receive(:each_object).with(Object).and_yield(obj1).and_yield(obj2)
  end

  describe '#list_ids' do
    subject { tracker.list_ids }

    it 'provides all objects ids' do
      expect(subject).to eq Set[obj1.__id__, obj2.__id__]
    end

    context 'when ignored_types passed' do
      let(:ignored_types) { [Dummy] }

      it 'filters objects' do
        expect(subject).to eq Set[obj1.__id__]
      end
    end
  end

  describe '#list' do
    subject { tracker.list(except_ids: except_ids) }

    let(:except_ids) { [] }

    it 'provides all objects' do
      expect(subject).to eq [obj1, obj2]
    end

    context 'when ignored_types passed' do
      let(:ignored_types) { [Dummy] }

      it 'filters objects' do
        expect(subject).to eq [obj1]
      end
    end

    context 'when ignored_types passed' do
      let(:except_ids) { [obj1.__id__] }

      it 'provides all objects' do
        expect(subject).to eq [obj2]
      end
    end
  end

  describe '#created_during' do
    subject { tracker.created_during {} }

    it 'lists objects' do
      expect(tracker).to receive(:list_ids) { [1, 2] }
      expect(tracker).to receive(:list).with(except_ids: [1, 2]) { [3] }
      expect(subject).to eq [3]
    end

    it 'yields a block' do
      expect do |b|
        tracker.created_during(&b)
      end.to yield_with_no_args
    end
  end
end
