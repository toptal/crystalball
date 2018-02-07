# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::SourceDiff do
  subject(:source_diff) { described_class.new(diff, repo) }
  let(:diff) { Git::Diff.new(repo) }
  let(:repo) { Crystalball::GitRepo.new('.') }
  let(:diff_file1) { Git::Diff::DiffFile.new(repo, path: 'file1.rb') }
  let(:diff_file2) { Git::Diff::DiffFile.new(repo, path: 'file2.rb') }

  before do
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
      let(:diff) { [] }
      it { is_expected.to be_empty }
    end
  end

  describe '#repository' do
    subject { source_diff.repository }

    it { is_expected.to eq(repo) }
  end

  describe '#from' do
    subject { source_diff.from }

    let(:diff) { Git::Diff.new(repo, from) }
    let(:from) { 'some_sha' }

    it { is_expected.to eq from }
  end

  describe '#to' do
    subject { source_diff.to }

    let(:diff) { Git::Diff.new(repo, '', to) }
    let(:to) { 'some_sha' }

    it { is_expected.to eq to }
  end
end
