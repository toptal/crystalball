# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator::AllocatedObjectsStrategy::ObjectTracker do
  subject(:tracker) { described_class.new(only_of: only_of) }

  let(:only_of) { ['Object'] }
  let(:obj1) { double }
  let(:obj2) { double(class: Dummy) }

  before do
    stub_const('Dummy', Class.new)
    allow(ObjectSpace).to receive(:each_object).with(Object).and_yield(obj1)
  end

  describe '#created_during' do
    subject do
      tracker.created_during do
        allow(ObjectSpace).to receive(:each_object).with(Object).and_yield(obj1).and_yield(obj2)
      end
    end

    it 'lists objects' do
      expect(subject).to eq [obj2]
    end

    it 'yields a block' do
      expect do |b|
        tracker.created_during(&b)
      end.to yield_with_no_args
    end
  end
end
