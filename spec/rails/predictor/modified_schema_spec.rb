# frozen_string_literal: true

require 'rails_helper'

describe Crystalball::Rails::Predictor::ModifiedSchema do
  subject(:predictor) { described_class.new(tables_map_path: tables_map_path) }
  let(:tables_map_path) { 'tables_map.yml' }
  let(:tables_map) { {} }

  before do
    allow(Crystalball::MapStorage::YAMLStorage).to receive(:load).with(Pathname(tables_map_path)) { tables_map }
  end

  it '#tables_map' do
    expect(subject.tables_map).to eq tables_map
  end

  describe '#call' do
    subject { predictor.call(diff, execution_map) }
    let(:diff) { [] }
    let(:execution_map) { instance_double('Crystalball::MapGenerator::ExecutionMap') }

    it { is_expected.to eq [] }

    context 'when schema was changed' do
      let(:tables_map) { {'dummies' => [model_path]} }
      let(:diff) { Crystalball::SourceDiff.new(nil) }
      let(:schema_diff) { Crystalball::SourceDiff::FileDiff.new(Git::Diff::DiffFile.new(repository, path: schema_path)) }
      let(:repository) { Git::Base.new }
      let(:repository_lib) { spy }
      let(:schema_path) { 'db/schema.rb' }
      let(:execution_map) { instance_double('Crystalball::MapGenerator::ExecutionMap', affected_examples: example_groups) }
      let(:example_groups) { ['spec_file'] }
      let(:model_path) { 'dummy.rb' }

      before do
        allow(diff).to receive(:changeset) { [schema_diff] }
        allow(diff).to receive(:repository) { repository }
        allow(diff).to receive(:from) { 'from' }
        allow(diff).to receive(:to) { 'to' }
        allow(repository).to receive(:lib) { repository_lib }
        allow(repository_lib).to receive(:show).with('from', schema_path) { 'schema_before' }
        allow(repository_lib).to receive(:show).with('to', schema_path) { 'schema_after' }
        allow(Crystalball::Rails::Helpers::SchemaDefinitionParser).to receive(:parse).with('schema_before') { {'dummies' => 1} }
        allow(Crystalball::Rails::Helpers::SchemaDefinitionParser).to receive(:parse).with('schema_after') { {'dummies' => 2} }
      end

      it 'predicts example' do
        is_expected.to eq ['spec_file']
      end

      context 'localy' do
        before do
          allow(diff).to receive('to') { nil }
          allow(repository).to receive(:dir) { double(path: '/wrk/') }
          allow(File).to receive(:read).with('/wrk/db/schema.rb') { 'schema_after' }
        end

        it 'predicts example' do
          is_expected.to eq ['spec_file']
        end
      end
    end
  end
end
