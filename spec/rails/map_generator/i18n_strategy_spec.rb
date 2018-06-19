# frozen_string_literal: true

require 'rails_helper'

describe Crystalball::Rails::MapGenerator::I18nStrategy do
  subject(:strategy) { described_class.new }

  include_examples 'base strategy'

  describe '#after_register' do
    subject { strategy.after_register }

    it do
      expect(Crystalball::Rails::MapGenerator::I18nStrategy::SimplePatch).to receive(:apply!)
      subject
    end
  end

  describe '#before_finalize' do
    subject { strategy.before_finalize }

    specify do
      expect(Crystalball::Rails::MapGenerator::I18nStrategy::SimplePatch).to receive(:revert!)
      subject
    end
  end

  describe '#call' do
    let(:example_group_map) { [] }

    it 'pushes used files to example group map' do
      allow(strategy).to receive(:filter).with(['view']).and_return([1, 2, 3])

      expect do
        subject.call(example_group_map, nil) do
          Crystalball::Rails::MapGenerator::I18nStrategy.locale_files.push 'view'
        end
      end.to change { example_group_map }.to [1, 2, 3]
    end

    it 'yields example_group_map to a block' do
      allow(strategy).to receive(:filter).with([]).and_return([])

      expect do |b|
        subject.call(example_group_map, nil, &b)
      end.to yield_with_args(example_group_map)
    end
  end
end
