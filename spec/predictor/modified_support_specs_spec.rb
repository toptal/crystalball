# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::Predictor::ModifiedSupportSpecs do
  subject(:predictor) { described_class.new }
  let(:repository) { Git::Base.new }
  let(:path1) { 'spec/support/some_shared_context.rb' }
  let(:file_diff1) { Crystalball::SourceDiff::FileDiff.new(Git::Diff::DiffFile.new(repository, path: path1)) }
  let(:diff) { [file_diff1] }
  let(:map) { Crystalball::ExecutionMap.new(map_data_source: map_data_source) }
  let(:map_data_source) { Crystalball::MapDataSources::HashDataSource.new(example_groups: example_groups) }
  let(:example_groups) { {'spec_file[1:2]': [path1]} }

  describe '#call' do
    subject { predictor.call(diff, map) }

    it { is_expected.to eq(['./spec_file']) }

    context 'when path does not match pattern' do
      let(:path1) { 'file1.rb' }

      it { is_expected.to eq([]) }
    end
  end
end
