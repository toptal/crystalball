# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::Predictor::Strategy do
  subject do
    Object.new.tap { |obj| obj.extend(described_class) }
  end

  describe '#call' do
    it 'formats any output provided by implementation' do
      expect(subject.call { ['one.rb', './two.rb'] }).to eq(['./one.rb', './two.rb'])
    end
  end
end
