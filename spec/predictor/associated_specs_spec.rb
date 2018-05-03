# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::Predictor::AssociatedSpecs do
  subject(:predictor) { described_class.new from: %r{models/(?<file>.*).rb}, to: 'spec/%<file>s_spec.rb' }
  let(:path1) { 'models/file1.rb' }
  let(:spec_path1) { 'spec/file1_spec.rb' }
  let(:diff) { [double(relative_path: path1)] }

  describe '#call' do
    subject { predictor.call(diff, {}) }

    it { is_expected.to eq(["./#{spec_path1}"]) }

    context 'when path does not match pattern' do
      let(:path1) { 'file1.rb' }

      it { is_expected.to eq([]) }
    end

    context 'without named captures' do
      let(:predictor) { described_class.new from: /Gemfile/, to: './spec' }
      let(:path1) { 'Gemfile' }

      it { is_expected.to eq ['./spec'] }
    end
  end
end
