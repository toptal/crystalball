# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::Predictor do
  subject(:predictor) { described_class.new(map, diff) }
  let(:repository) { Git::Base.new }
  let(:path1) { 'file1.rb' }
  let(:file_diff1) { Crystalball::SourceDiff::FileDiff.new(repository, Git::Diff::DiffFile.new(repository, path: path1)) }
  let(:diff) { [file_diff1] }
  let(:map) { instance_double('Crystalball::MapGenerator::StandardMap', cases: cases) }
  let(:cases) { {spec_file: %w[file1.rb]} }

  describe '#cases' do
    subject { predictor.cases }

    it { is_expected.to eq([]) }

    context 'with predictor' do
      before { predictor.use ->(diff, map) { map.cases.keys unless diff.empty? } }

      it { is_expected.to eq([:spec_file]) }

      context 'when diff is not present' do
        let(:diff) { [] }

        it { is_expected.to eq([nil]) }
      end
    end
  end
end
