# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapCompactor do
  describe '.compact_map!' do
    subject { described_class.compact_map!(map) }
    let(:map) { Crystalball::ExecutionMap.new(map_data_source: map_data_source) }
    let(:map_data_source) { Crystalball::MapDataSources::HashDataSource.new(example_groups: example_groups) }
    let(:example_groups) { {} }

    it 'compacts a map per file and stores it in new map' do
      expect(described_class)
        .to receive(:compact_examples!).with(example_groups)
                                       .and_return('file1_spec.rb[context1]' => ['value1'], 'file2_spec.rb[context2]' => ['value2'])

      expect(subject.metadata.to_h).to eq map.metadata.to_h
      expect(subject.example_groups)
        .to eq(
          'file1_spec.rb[context1]' => ['value1'],
          'file2_spec.rb[context2]' => ['value2']
        )
    end
  end

  describe '.compact_examples!' do
    subject { described_class.compact_examples!(example_groups) }
    let(:example_groups) { file1_examples.merge(file2_examples) }
    let(:file1_examples) do
      {'file1_spec.rb[1:1:1]' => 1, 'file1_spec.rb[1:2:3]' => 2}
    end
    let(:file2_examples) do
      {'file2_spec.rb[1]' => 3}
    end

    it 'compacts a map per file and stores it in new map' do
      expect(Crystalball::MapCompactor::ExampleGroupsDataCompactor)
        .to receive(:compact!).with(file1_examples).once.and_return('context1' => ['value1'])
      expect(Crystalball::MapCompactor::ExampleGroupsDataCompactor)
        .to receive(:compact!).with(file2_examples).once.and_return('context2' => ['value2'])

      expect(subject).to eq('file1_spec.rb[context1]' => ['value1'], 'file2_spec.rb[context2]' => ['value2'])
    end
  end
end
