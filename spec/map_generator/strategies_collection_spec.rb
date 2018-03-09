# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator::StrategiesCollection do
  subject { described_class.new }

  let(:strategy1) do
    lambda do |val, example, &block|
      val.push('1')
      val.push(example)
      block.call(val)
      val.push('1')
    end
  end

  let(:strategy2) do
    lambda do |val, _example, &block|
      val.push('2')
      val.push('example')
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
    let(:example) { 'example' }

    before do
      subject.push(strategy1, strategy2)
    end

    it 'wraps strategies one into another' do
      result = []
      expect do
        subject.run(result, example) { |v| v.push('BLOCK') }
      end.to change { result }.to(%w[2 example 1 example BLOCK 1 2])
    end
  end
end
