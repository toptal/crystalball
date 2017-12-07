# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::Predictor do
  subject(:predictor) { described_class.new(map, diff) }
  let(:repository) { Git::Base.new }
  let(:file_diff1) { Crystalball::SourceDiff::FileDiff.new(repository, Git::Diff::DiffFile.new(repository, path: 'file1.rb')) }
  let(:diff) { [file_diff1] }
  let(:map) { {spec_file: %w[file1.rb]} }

  describe '#cases' do
    subject { predictor.cases }

    it { is_expected.to eq([:spec_file]) }

    context 'when no files match diff' do
      let(:map) { {spec_file: %w[file2.rb]} }

      it { is_expected.to eq([]) }
    end

    context 'when some files match diff' do
      let(:map) { {spec_file: %w[file2.rb file1.rb]} }

      it { is_expected.to eq([:spec_file]) }
    end

    context 'when diff contains other unrelated files' do
      let(:file_diff2) { Crystalball::SourceDiff::FileDiff.new(repository, Git::Diff::DiffFile.new(repository, path: 'file2.rb')) }
      let(:diff) { [file_diff1, file_diff2] }

      it { is_expected.to eq([:spec_file]) }
    end
  end
end
