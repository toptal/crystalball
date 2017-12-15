# frozen_string_literal: true

require 'spec_helper'

require 'crystalball/map_generator/simple_map'

describe Crystalball::MapGenerator::SimpleMap do
  subject { described_class.new(storage) }
  let(:storage) { instance_double(Crystalball::MapStorage::YAMLStorage) }
  let(:coverage) { double }
  let(:case_map) { instance_double(Crystalball::CaseMap, case_uid: 'file_spec.rb:1', coverage: coverage) }

  describe '#stash' do
    it 'adds case to data' do
      expect do
        subject.stash(case_map)
      end.to change { subject.cases }.to('file_spec.rb:1' => coverage)
    end
  end

  describe '#dump' do
    it 'saves the map to storage' do
      expect(storage).to receive(:dump).with(subject)
      subject.dump
    end
  end

  describe '#to_h' do
    it 'returns hash with cases and metadata' do
      subject.commit = 'abc'
      subject.stash(case_map)
      expect(subject.to_h).to eq(metadata: {type: 'Crystalball::MapGenerator::SimpleMap', commit: 'abc'},
                                 cases: {'file_spec.rb:1' => coverage})
    end
  end
end
