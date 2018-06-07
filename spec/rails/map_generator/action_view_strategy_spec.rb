# frozen_string_literal: true

require 'rails_helper'

describe Crystalball::Rails::MapGenerator::ActionViewStrategy do
  subject(:strategy) { described_class.new }

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
    let(:case_map) { instance_double('Crystalball::CaseMap', push: nil) }

    it 'pushes affected files to case map' do
      allow(strategy).to receive(:filter).with(['view']).and_return([1, 2, 3])
      expect(case_map).to receive(:push).with(1, 2, 3, strategy: 'action_view_strategy')

      subject.call(case_map, 'example') do
        Crystalball::Rails::MapGenerator::ActionViewStrategy.views.push 'view'
      end
    end

    it 'yields case_map to a block' do
      allow(strategy).to receive(:filter).with([]).and_return([])

      expect do |b|
        subject.call(case_map, 'example', &b)
      end.to yield_with_args(case_map)
    end
  end
end
