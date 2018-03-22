# frozen_string_literal: true

require 'spec_helper'

describe Schema1 do
  describe '.types' do
    subject(:types) { described_class.types }

    it 'includes Type1' do
      expect(types).to include('Type1')
    end

    it 'executes queries' do
      described_class.execute('{foo}')
    end
  end
end
