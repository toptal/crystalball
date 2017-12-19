# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::Predictor::ModifiedSpecs do
  subject(:predictor) { described_class.new }
  let(:repository) { Git::Base.new }
  let(:path1) { 'spec/models/user_spec.rb' }
  let(:file_diff1) { Crystalball::SourceDiff::FileDiff.new(repository, Git::Diff::DiffFile.new(repository, path: path1)) }
  let(:diff) { [file_diff1] }

  describe '#call' do
    subject { predictor.call(diff, {}) }

    it { is_expected.to eq([path1]) }

    context 'when path does not match pattern' do
      let(:path1) { 'file1.rb' }

      it { is_expected.to eq([]) }
    end
  end
end
