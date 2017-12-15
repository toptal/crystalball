# frozen_string_literal: true

require 'spec_helper'

require 'crystalball/source_diff'

describe Crystalball::SourceDiff do
  subject { described_class.new(repo) }
  let(:repo) { Crystalball::GitRepo.new('.') }
  let(:diff) { Git::Diff.new(repo) }
  let(:diff_file1) { Git::Diff::DiffFile.new(repo, path: 'file1.rb') }
  let(:diff_file2) { Git::Diff::DiffFile.new(repo, path: 'file2.rb') }

  describe '#each' do
    before do
      allow(repo).to receive(:diff).with(no_args) { diff }
      allow(diff).to receive(:each).with(no_args).and_yield(diff_file1).and_yield(diff_file2)
    end

    it 'yields all changed files' do
      paths = []
      subject.each { |file_diff| paths << file_diff.relative_path }
      expect(paths).to contain_exactly('file1.rb', 'file2.rb')
    end
  end
end
