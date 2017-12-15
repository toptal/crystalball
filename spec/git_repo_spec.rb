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
