# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::Predictor do
  subject(:predictor) { described_class.new(instance_double('Crystalball::ExecutionMap', cases: cases), repository) }
  let(:cases) { {spec_file: %w[file1.rb]} }
  let(:repository) { double('Crystalball::GitRepo', merge_base: double(sha: nil), repo_path: Pathname('.')) }
  let(:map) { instance_double('Crystalball::MapGenerator::ExecutionMap', cases: cases) }
  let(:cases) { {'spec_file' => %w[file1.rb]} }

  describe '#initialize' do
    it 'yields block with self' do
      expect do |b|
        described_class.new(double, repository, &b)
      end.to yield_with_args(kind_of(Crystalball::Predictor))
    end
  end

  describe '#prediction' do
    subject { predictor.prediction.to_a }

    let(:source_diff) { instance_double('Crystalball::SourceDiff') }

    before do
      allow(repository).to receive(:diff).and_return(source_diff)
    end

    it { is_expected.to eq([]) }

    context 'with predictor' do
      before { predictor.use ->(_source_diff, map) { map.cases.keys } }

      context 'when file is present' do
        before do
          allow_any_instance_of(Pathname).to receive(:exist?).and_return true
        end

        it { is_expected.to eq(['spec_file']) }
      end

      context 'when diff is not present' do
        it { is_expected.to eq([]) }
      end
    end
  end
end
