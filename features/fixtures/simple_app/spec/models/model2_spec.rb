# frozen_string_literal: true

require 'spec_helper'

describe Model2 do
  describe '.table_name' do
    subject { described_class.table_name }

    it { is_expected.to eq 'model2s' }
  end
end
