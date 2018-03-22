# frozen_string_literal: true

require 'spec_helper'

describe Schema2 do
  describe '.types' do
    subject(:types) { described_class.types }

    it 'includes Type1 and Type2' do
      expect(types).to include('Type1', 'Type2')
    end

    it 'executes queries' do
      described_class.execute('{foo}')
    end
  end
end
