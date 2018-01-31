# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::Predictor do
  subject(:predictor) { described_class.new(instance_double('Crystalball::ExecutionMap', cases: cases), source_diff) }
  let(:cases) { {spec_file: %w[file1.rb]} }
  let(:repository) { Git::Base.open Dir.pwd }
  let(:path1) { 'file1.rb' }
  let(:file_diff1) { Git::Diff::DiffFile.new(repository, path: path1) }
  let(:diff) { Git::Diff.new(repository) }
  let(:source_diff) { Crystalball::SourceDiff.new(diff) }
  let(:map) { instance_double('Crystalball::MapGenerator::StandardMap', cases: cases) }
  let(:cases) { {'spec_file' => %w[file1.rb]} }

  before do
    allow(diff).to receive(:each).and_yield([file_diff1])
  end

  describe '#initialize' do
    it 'yields block with self' do
      expect do |b|
        described_class.new(double, source_diff, &b)
      end.to yield_with_args(kind_of(Crystalball::Predictor))
    end
  end

  describe '#cases' do
    subject { predictor.cases }

    it { is_expected.to eq([]) }

    context 'with predictor' do
      before { predictor.use ->(source_diff, map) { map.cases.keys unless source_diff.empty? } }

      context 'when file is present' do
        before do
          spec_path = File.join(repository.dir.path, 'spec_file')
          allow(File).to receive(:exist?).with(spec_path) { true }
        end

        it { is_expected.to eq(['spec_file']) }
      end

      context 'when diff is not present' do
        let(:source_diff) { [] }

        it { is_expected.to eq([]) }
      end
    end
  end
end
