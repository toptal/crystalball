# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::GitRepo do
  subject(:git_repo) { described_class.new(Pathname('.')) }

  describe 'open' do
    subject { described_class.open('.') }

    context 'when .git directory exist' do
      before do
        allow(described_class).to receive(:exists?).with(Pathname('.')).and_return true
      end

      it { is_expected.to be_a described_class }
    end

    context 'when .git directory does not exist' do
      before do
        allow(described_class).to receive(:exists?).with(Pathname('.')).and_return false
      end

      it { is_expected.to eq nil }
    end
  end

  describe '.exists?' do
    subject { described_class.exists?(Pathname('.')) }

    context 'when .git directory exist' do
      before do
        allow_any_instance_of(Pathname).to receive(:directory?).and_return true
      end

      it { is_expected.to be_truthy }
    end

    context 'when .git directory does not exist' do
      before do
        allow_any_instance_of(Pathname).to receive(:directory?).and_return false
      end

      it { is_expected.to be_falsey }
    end
  end

  describe '#diff' do
    let(:diff) { Git::Diff.new(repo) }
    let(:repo) { Crystalball::GitRepo.new('.') }
    let(:expected_source_diff) { instance_double('Crystalball::SourceDiff') }

    specify do
      allow_any_instance_of(Git::Base).to receive(:diff).and_return(diff)
      allow(Crystalball::SourceDiff).to receive(:new).with(diff).and_return(expected_source_diff)
      expect(subject.diff).to eq expected_source_diff
    end
  end

  describe '#method_missing' do
    it 'delegates to #repo' do
      expect(subject.lib).to eq subject.instance_variable_get(:@repo).lib
    end
  end

  describe '#respond_to?' do
    it 'includes method_missing' do
      expect(subject.respond_to?(:lib)).to be_truthy
    end
  end
end
