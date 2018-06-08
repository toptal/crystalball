# frozen_string_literal: true

require 'spec_helper'
require 'crystalball/factory_bot'

describe Crystalball::MapGenerator::FactoryBotStrategy do
  subject(:strategy) { described_class.new }

  include_examples 'base strategy'

  describe '.factory_bot_constant' do
    subject { described_class.factory_bot_constant }

    it { is_expected.to eq ::FactoryBot }

    context 'when FactoryGirl is defined instead of FactoryBot' do
      before do
        ::FactoryGirl = ::FactoryBot
        Object.send(:remove_const, :FactoryBot)
      end

      it { is_expected.to eq ::FactoryGirl }
    end
  end

  describe '.factory_definitions' do
    subject { described_class.factory_definitions }

    it 'is an empty hash by default' do
      is_expected.to eq({})
    end
  end

  describe '#after_register' do
    subject { strategy.after_register }

    it do
      expect(Crystalball::MapGenerator::FactoryBotStrategy::DSLPatch).to receive(:apply!)
      expect(Crystalball::MapGenerator::FactoryBotStrategy::FactoryRunnerPatch).to receive(:apply!)
      subject
    end
  end

  describe '#call' do
    let(:example_map) { [] }

    it 'pushes affected files to example map' do
      allow(strategy).to receive(:filter).with(['factories/dummy.rb']).and_return([1, 2, 3])
      allow(Crystalball::MapGenerator::FactoryBotStrategy).to receive(:factory_definitions) { {'dummy' => %w[factories/dummy.rb]} }

      expect do
        subject.call(example_map, 'example') do
          Crystalball::MapGenerator::FactoryBotStrategy.used_factories.push 'dummy'
        end
      end.to change { example_map }.to [1, 2, 3]
    end

    it 'yields example_map to a block' do
      allow(strategy).to receive(:filter).with([]).and_return([])

      expect do |b|
        subject.call(example_map, 'example', &b)
      end.to yield_with_args(example_map, 'example')
    end
  end
end
