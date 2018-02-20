# frozen_string_literal: true

require 'spec_helper'

describe Class2 do
  include_examples 'module1'

  describe '#bar' do
    subject { super().bar }

    it { is_expected.to eq 'bar of Class2' }
  end

  describe '.another_field' do
    subject { described_class.another_field }

    before { described_class.another_field = 'value' }

    it { expect(subject).to eq 'value' }
  end
end
