# frozen_string_literal: true

require 'spec_helper'

describe QueryType1 do
  describe '.fields' do
    subject(:fields) { described_class.fields }

    it 'includes Type1' do
      expect(fields.values.map(&:type)).to include(Type1)
    end
  end
end
