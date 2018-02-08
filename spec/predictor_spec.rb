# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::Predictor do
  subject(:predictor) { described_class.new(instance_double('Crystalball::ExecutionMap', cases: cases), repository) }
  let(:cases) { {spec_file: %w[file1.rb]} }
  let(:repository) do
    instance_double('Crystalball::GitRepo', repo_path: Pathname('.'), diff: source_diff)
  end
  let(:source_diff) { instance_double('Crystalball::SourceDiff') }
  let(:map) { instance_double('Crystalball::MapGenerator::StandardMap', cases: cases) }
  let(:cases) { {'spec_file' => %w[file1.rb]} }

  describe '#initialize' do
    it 'yields block with self' do
      expect do |b|
        described_class.new(double, repository, &b)
      end.to yield_with_args(kind_of(Crystalball::Predictor))
    end
  end

  describe '#cases' do
    subject { predictor.cases }

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
