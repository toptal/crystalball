# frozen_string_literal: true

require 'spec_helper'

require 'crystalball/git_repo'

describe Crystalball::GitRepo do
  subject(:git_repo) { described_class.new('.') }

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
