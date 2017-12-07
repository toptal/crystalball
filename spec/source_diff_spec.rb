require 'spec_helper'

describe Crystalball::SourceDiff do
  subject { described_class.new(path) }
  let(:path) { '/projects' }
  let(:repository) { Git::Base.new }
  let(:diff) { Git::Diff.new(repository) }
  let(:diff_file1) { Git::Diff::DiffFile.new(repository, path: 'file1.rb') }
  let(:diff_file2) { Git::Diff::DiffFile.new(repository, path: 'file2.rb') }

  describe '#each' do
    before do
      allow(Git).to receive(:open).with(path) { repository }
      allow(repository).to receive(:diff).with(no_args) { diff }
      allow(diff).to receive(:each).with(no_args).and_yield(diff_file1).and_yield(diff_file2)
    end

    it 'yields all changed files' do
      paths = []
      subject.each { |file_diff| paths << file_diff.path }
      expect(paths).to contain_exactly('file1.rb', 'file2.rb')
    end
  end
end
