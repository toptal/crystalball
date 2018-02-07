# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator::StrategiesCollection do
  subject { described_class.new }

  let(:strategy1) do
    lambda do |val, &block|
      val.push('1')
      block.call(val)
      val.push('1')
    end
  end

  let(:strategy2) do
    lambda do |val, &block|
      val.push('2')
      block.call(val)
      val.push('2')
    end
  end

  describe '#method_missing' do
    it 'delegates to strategies array' do
      expect(subject).to respond_to :empty?
      expect(subject).to be_empty
    end
  end

  describe '#run' do
    before do
      subject.push(strategy1, strategy2)
    end

    it 'wraps strategies one into another' do
      result = []
      expect do
        subject.run(result) { |v| v.push('BLOCK') }
      end.to change { result }.to(%w[2 1 BLOCK 1 2])
    end
  end
end
