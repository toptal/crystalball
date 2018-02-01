# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::CaseMap do
  subject(:case_map) { described_class.new(example, coverage) }
  let(:example) { double(id: 'file_spec.rb:5') }
  let(:coverage) { double }

  describe '#uid' do
    subject { case_map.uid }
    it { is_expected.to eq('file_spec.rb:5') }
  end
end
