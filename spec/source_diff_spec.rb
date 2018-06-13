# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::SourceDiff do
  subject(:source_diff) { described_class.new(diff) }
  let(:diff) { Git::Diff.new(repo) }
  let(:repo) { Crystalball::GitRepo.new('.') }
  let(:diff_file1) { instance_double('Git::Diff::DiffFile', path: 'file1.rb', type: 'modified', patch: "+ 's'") }
  let(:diff_file2) { instance_double('Git::Diff::DiffFile', path: 'file2.rb', type: 'modified', patch: "+ 's'") }

  before do
    allow(diff).to receive(:each).with(no_args).and_yield(diff_file1).and_yield(diff_file2)
  end

  describe '#each' do
    it 'yields all changed files' do
      paths = []
      subject.each { |file_diff| paths << file_diff.relative_path }
      expect(paths).to contain_exactly('file1.rb', 'file2.rb')
    end

    context 'when one of diff is formatting only' do
      let(:diff_file2) { instance_double('Git::Diff::DiffFile', path: 'file2.rb', type: 'modified', patch: '') }

      it 'yields all changed files' do
        paths = []
        subject.each { |file_diff| paths << file_diff.relative_path }
        expect(paths).to contain_exactly('file1.rb')
      end
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

    it { is_expected.to eq repo }
  end
end
