# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::SourceDiff::FormattingChecker do
  describe '.pure_formatting?' do
    subject { described_class.pure_formatting?(file_diff) }
    let(:file_diff) { double(path: path, patch: patch, **flags) }
    let(:path) { 'lib/crystalball.rb' }
    let(:patch) { " 'some here'\n+ 's'\n-'a'\t" }
    let(:flags) { {modified?: modified, moved?: moved, new?: new, deleted?: deleted} }
    let(:modified) { true }
    let(:moved) { false }
    let(:new) { false }
    let(:deleted) { false }

    it { is_expected.to eq false }

    context 'when patch is with whitespace only' do
      let(:patch) { "+ \n" }

      it { is_expected.to eq true }
    end

    context 'when patch for ERB file' do
      let(:path) { 'lib/template.erb' }

      it { is_expected.to eq false }
    end

    context 'when patch contains a comment only' do
      let(:patch) { " 'some here'\n+ # one\n- # another" }

      it { is_expected.to eq true }
    end

    context 'when file is not for .rb or .erb file' do
      let(:path) { 'lib/index.html' }

      it { is_expected.to eq false }
    end

    context 'when file was moved' do
      let(:modified) { false }
      let(:moved) { true }

      it { is_expected.to eq false }
    end

    context 'when file was added' do
      let(:modified) { false }
      let(:added) { true }

      it { is_expected.to eq false }
    end

    context 'when file was deleted' do
      let(:modified) { false }
      let(:deleted) { true }

      it { is_expected.to eq false }
    end
  end
end
