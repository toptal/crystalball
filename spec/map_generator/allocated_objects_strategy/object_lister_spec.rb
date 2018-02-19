# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator::AllocatedObjectsStrategy::ObjectLister do
  subject(:lister) { described_class.new(ignored_types) }

  let(:ignored_types) { [] }
  let(:obj1) { double }
  let(:obj2) { double(class: stub_const('Dummy', Class.new)) }

  before do
    allow(ObjectSpace).to receive(:each_object).with(Object).and_yield(obj1).and_yield(obj2)
  end

  describe '#list_ids' do
    subject { lister.list_ids }

    it 'provides all objects ids' do
      expect(subject).to eq Set[obj1.__id__, obj2.__id__]
    end

    context 'filters objects' do
      let(:ignored_types) { [Dummy] }

      specify do
        expect(subject).to eq Set[obj1.__id__]
      end
    end
  end

  describe '#list' do
    subject { lister.list(except_ids: except_ids) }

    let(:except_ids) { [] }

    it 'provides all objects' do
      expect(subject).to eq [obj1, obj2]
    end

    context 'filters objects by type' do
      let(:ignored_types) { [Dummy] }

      specify do
        expect(subject).to eq [obj1]
      end
    end

    context 'filters objects by type' do
      let(:except_ids) { [obj1.__id__] }

      specify do
        expect(subject).to eq [obj2]
      end
    end
  end

  describe '#created_during' do
    subject { lister.created_during {} }

    it 'lists objects' do
      expect(lister).to receive(:list_ids) { [1, 2] }
      expect(lister).to receive(:list).with(except_ids: [1, 2]) { [3] }
      expect(subject).to eq [3]
    end

    it 'yields a block' do
      expect do |b|
        lister.created_during(&b)
      end.to yield_with_no_args
    end
  end
end
