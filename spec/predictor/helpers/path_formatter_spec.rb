# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::Predictor::Helpers::PathFormatter do
  subject do
    Object.new.tap { |obj| obj.extend(described_class) }
  end

  describe '#format_path' do
    it 'adds ./ when missing' do
      expect(subject.format_path('test.rb')).to eq './test.rb'
    end

    it 'does nothing when ./ is present' do
      expect(subject.format_path('./test.rb')).to eq './test.rb'
    end
  end

  describe '#format_paths' do
    it 'returns an array of formatted paths' do
      expect(subject.format_paths(['one.rb', './two.rb'])).to eq(['./one.rb', './two.rb'])
    end
  end
end
