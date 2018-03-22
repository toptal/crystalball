# frozen_string_literal: true

require 'spec_helper'

describe Type2 do
  describe '.fields' do
    subject(:fields) { described_class.fields }

    it 'includes String' do
      expect(fields.values.map(&:type)).to include(GraphQL::STRING_TYPE)
    end
  end
end
