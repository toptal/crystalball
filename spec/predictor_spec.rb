# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::Predictor do
  subject(:predictor) { described_class.new(instance_double('Crystalball::ExecutionMap', cases: cases), source_diff) }
  let(:repository) { double('Crystalball::GitRepo', dir: instance_double('Git::WorkingDirectory', path: Dir.pwd)) }
  let(:source_diff) { instance_double('Crystalball::SourceDiff', repository: repository, to: revision) }
  let(:revision) { 'some_sha' }
  let(:map) { instance_double('Crystalball::MapGenerator::StandardMap', cases: cases) }
  let(:cases) { {'./spec_file[1:1]' => %w[file1.rb]} }

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
      before do
        predictor.use ->(_source_diff, map) { map.cases.keys }
        allow(source_diff).to receive(:path_exist?).with('spec_file') { path_present }
      end

      context 'when file is present' do
        let(:path_present) { true }

        it { is_expected.to eq(['./spec_file[1:1]']) }
      end

      context 'when diff is not present' do
        let(:path_present) { false }

        it { is_expected.to eq([]) }
      end
    end
  end
end
