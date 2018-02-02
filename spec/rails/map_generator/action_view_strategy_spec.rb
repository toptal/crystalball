# frozen_string_literal: true

require 'rails_helper'

describe Crystalball::Rails::MapGenerator::ActionViewStrategy do
  subject(:strategy) { described_class.new(execution_detector) }
  let(:execution_detector) { instance_double('Crystalball::Rails::MapGenerator::ActionViewStrategy::ExecutionDetector') }

  include_examples 'base strategy'

  describe '#after_start' do
    subject { strategy.after_start }

    it do
      expect(Crystalball::Rails::MapGenerator::ActionViewStrategy::Patch).to receive(:apply!)
      subject
    end
  end

  describe '#before_finalize' do
    subject { strategy.before_finalize }

    specify do
      expect(Crystalball::Rails::MapGenerator::ActionViewStrategy::Patch).to receive(:revert!)
      subject
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
