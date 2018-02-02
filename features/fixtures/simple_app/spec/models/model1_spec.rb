# frozen_string_literal: true

require 'spec_helper'

describe Model1 do
  describe '.table_name' do
    subject { described_class.table_name }

    it { is_expected.to eq 'model1' }
  end

  describe '#field' do
    subject { described_class.new('value').field }

    it { is_expected.to eq 'value' }
  end
end
