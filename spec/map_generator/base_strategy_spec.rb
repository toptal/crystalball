# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator::BaseStrategy do
  subject do
    Object.new.tap do |o|
      o.extend described_class
    end
  end
  include_examples 'base strategy'

  describe '#call' do
    specify do
      expect do
        subject.call(1)
      end.to raise_error NotImplementedError
    end
  end
end
