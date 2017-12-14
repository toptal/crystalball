# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::CaseMap do
  subject(:case_map) { described_class.new(example, coverage) }
  let(:example) { double(location_rerun_argument: 'file_spec.rb:5') }
  let(:coverage) { double }

  describe '#case_uid' do
    subject { case_map.case_uid }
    it { is_expected.to eq('file_spec.rb:5') }
  end

  describe '#coverage' do
    subject { case_map.coverage }
    it { is_expected.to eq(coverage) }
  end
end
