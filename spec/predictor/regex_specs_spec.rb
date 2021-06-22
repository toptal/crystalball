# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::Predictor::RegexSpecs do
  subject(:predictor) { described_class.new scope: 'spec/data/**/*_spec.rb', from: %r{models/(?<file>.*).rb}, to: 'spec/data/%<file>s/(.*).rb' }
  let(:path1) { 'models/file1.rb' }
  let(:spec_file1_spec1) { 'spec/data/file1/spec1_spec.rb' }
  let(:spec_file1_spec2) { 'spec/data/file1/spec2_spec.rb' }
  let(:spec_file2_spec1) { 'spec/data/file2/spec1_spec.rb' }
  let(:spec_file2_spec2) { 'spec/data/file2/spec1_spec.rb' }
  let(:diff) { [double(relative_path: path1)] }

  describe '#call' do
    subject { predictor.call(diff, {}) }

    it { is_expected.to eq(["./#{spec_file1_spec1}", "./#{spec_file1_spec2}"]) }

    context 'when path does not contain specs' do
        let(:path1) { 'models/file3.rb' }

        it { is_expected.to eq([]) }
    end

    context 'when path does not match "FROM" pattern' do
        let(:path1) { 'lib/file3.rb' }

        it { is_expected.to eq([]) }
    end

    context 'when path is out of scope' do
        let(:predictor) { described_class.new scope: 'spec/data/file1/*_spec.rb', from: %r{models/(?<file>.*).rb}, to: 'spec/data/%<file>s/(.*).rb' }
        let(:path1) { 'models/file2.rb' }

        it { is_expected.to eq([]) }
    end

    context 'without named captures' do
        let(:predictor) { described_class.new scope: 'spec', from: /Gemfile/, to: 'spec' }
        let(:path1) { 'Gemfile' }

      it { is_expected.to eq ["./spec"] }
    end
  end
end
