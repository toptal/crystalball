# frozen_string_literal: true

require 'spec_helper'

require 'crystalball/source_diff'

describe Crystalball::SourceDiff do
  subject { described_class.new(repo) }
  let(:repo) { Crystalball::GitRepo.new('.') }
  let(:diff) { Git::Diff.new(repo) }
  let(:diff_file1) { Git::Diff::DiffFile.new(repo, path: 'file1.rb') }
  let(:diff_file2) { Git::Diff::DiffFile.new(repo, path: 'file2.rb') }

  before do
    allow(repo).to receive(:diff).with(no_args).and_return(diff)
    allow(diff).to receive(:each).with(no_args).and_yield(diff_file1).and_yield(diff_file2)
  end

  describe '#each' do
    it 'yields all changed files' do
      paths = []
      subject.each { |file_diff| paths << file_diff.relative_path }
      expect(paths).to contain_exactly('file1.rb', 'file2.rb')
    end
  end

  describe '#empty?' do
    context 'when there is a changeset' do
      it { is_expected.not_to be_empty }
    end

    context 'when there is an empty changeset' do
      before do
        allow(repo).to receive(:diff).with(no_args).and_return([])
      end
      it { is_expected.to be_empty }
    end
  end
end
