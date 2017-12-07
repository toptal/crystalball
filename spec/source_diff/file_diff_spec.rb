# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::SourceDiff::FileDiff do
  subject(:file_diff) { described_class.new(repository, diff_file) }
  let(:repository) { Git::Base.new }
  let(:type) {}
  let(:path) { 'lib/crystalball.rb' }
  let(:diff_file) { Git::Diff::DiffFile.new(repository, type: type, path: path) }

  %i[modified deleted new].each do |type|
    context "##{type}?" do
      subject { file_diff.send("#{type}?") }

      it { is_expected.to be_falsey }

      context 'with correct type' do
        let(:type) { type.to_s }

        it { is_expected.to be_truthy }
      end
    end
  end

  describe '#relative_path' do
    subject { file_diff.relative_path }
    it { is_expected.to eq('lib/crystalball.rb') }
  end

  describe '#full_path' do
    subject { file_diff.full_path }
    before { allow(repository).to receive(:dir) { Git::WorkingDirectory.new('/projects', false) } }
    it { is_expected.to eq('/projects/lib/crystalball.rb') }
  end
end
