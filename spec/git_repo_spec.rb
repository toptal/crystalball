# frozen_string_literal: true

require 'spec_helper'

require 'crystalball/git_repo'

describe Crystalball::GitRepo do
  subject(:git_repo) { described_class.new('.') }

  describe '#source_diff' do
    subject { git_repo.source_diff }
    specify do
      expect(subject).to be_a(Crystalball::SourceDiff)
      expect(subject.repo).to eq git_repo
    end
  end

  describe '#pristine?' do
    context 'with untouched repo' do
      before do
        allow_any_instance_of(Crystalball::SourceDiff).to receive(:empty?).and_return(true)
      end
      it { is_expected.to be_pristine }
    end

    context 'with non-empty source diff' do
      before do
        allow_any_instance_of(Crystalball::SourceDiff).to receive(:empty?).and_return(false)
      end
      it { is_expected.not_to be_pristine }
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
