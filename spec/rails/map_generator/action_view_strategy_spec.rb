# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::Rails::MapGenerator::ActionViewStrategy do
  subject { described_class.new(execution_detector) }
  let(:execution_detector) { instance_double('Crystalball::Rails::MapGenerator::ActionViewStrategy::ExecutionDetector') }

  include_examples 'base strategy'

  describe '#after_start' do
    it 'starts patches ::ActionView::Template#compile!' do
      old_compile = ::ActionView::Template.instance_method(:compile!)
      subject.after_start
      expect(::ActionView::Template.instance_method(:compile!)).not_to eq old_compile
    end
  end

  describe '#before_finalize' do
    it 'restore old ::ActionView::Template#compile!' do
      old_compile = ::ActionView::Template.instance_method(:compile!)
      subject.after_start
      subject.before_finalize
      expect(::ActionView::Template.instance_method(:compile!)).to eq old_compile
    end
  end

  describe '#call' do
    let(:case_map) { [] }

    it 'pushes affected files detected by detector to case map' do
      allow(execution_detector).to receive(:detect).with(['view']).and_return([1, 2, 3])

      expect do
        subject.call(case_map) do
          Crystalball::Rails::MapGenerator::ActionViewStrategy.views.push 'view'
        end
      end.to change { case_map }.to [1, 2, 3]
    end

    it 'yields case_map to a block' do
      allow(execution_detector).to receive(:detect).with([]).and_return([])

      expect do |b|
        subject.call(case_map, &b)
      end.to yield_with_args(case_map)
    end
  end
end
