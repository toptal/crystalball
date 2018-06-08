# frozen_string_literal: true

require 'spec_helper'

describe Model1 do
  describe '.table_name' do
    subject { described_class.table_name }

    it { is_expected.to eq 'model1s' }
  end

  describe '#field' do
    subject { described_class.new(field: 'value').field }

    it { is_expected.to eq 'value' }
  end

  context 'using factory by name and without syntax included' do
    subject { FactoryBot.create(:model1) }

    it { is_expected.to have_attributes(name: 'John Doe', field: 'value') }
  end

  context 'using factory by alias and with syntax included' do
    subject { build_stubbed(:model_1) }

    it { is_expected.to have_attributes(name: 'John Doe', field: 'value') }
  end
end
