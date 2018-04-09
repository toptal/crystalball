# frozen_string_literal: true

require 'rails_helper'

describe Crystalball::Rails::Helpers::BaseSchemaParser do
  subject(:parser) { Class.new.tap { |c| c.include Crystalball::Rails::Helpers::BaseSchemaParser }.new }

  describe '.parse' do
    subject { described_class.parse }

    it 'raises NotImplementedError' do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end

  it '#respond_to_missing?' do
    expect(subject.respond_to?(:anything)).to eq true
  end

  describe '#method_missing' do
    it 'adds to hash' do
      expect { subject.some(1, 2, 3) }.to change(subject, :hash).to(1 => {options: [[:some, 2, 3]], content: [{}]})
    end
  end
end
