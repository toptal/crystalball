# frozen_string_literal: true

require 'spec_helper'

describe Class2 do
  let(:name) { 'Johanne Doe' }

  include_examples 'module1'

  describe '#bar' do
    subject { super().bar }

    it { is_expected.to eq 'bar of Class2' }
  end

  describe '.another_field' do
    subject { described_class.another_field }

    before { described_class.another_field = 'value' }

    it { is_expected.to eq 'value' }
  end

  describe '#translated_value' do
    subject { super().translated_value }

    it { is_expected.to eq 'Something' }
  end
end
