# frozen_string_literal: true

require 'spec_helper'

describe QueryType2 do
  describe '.fields' do
    subject(:fields) { described_class.fields }

    it 'includes Type1' do
      expect(fields.values.map(&:type)).to include(Type1, Type2)
    end
  end
end
