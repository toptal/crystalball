# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator::StandardMap do
  subject { described_class.new(storage, dump_threshold: 2) }
  let(:storage) { instance_double(Crystalball::MapStorage::YAMLStorage) }
  let(:coverage) { double }

  def case_map(index)
    instance_double(Crystalball::CaseMap, case_uid: "file_spec.rb:#{index}", coverage: coverage)
  end

  describe '#stash' do
    it 'dumps to storage every time threshold is met' do
      expect(subject).to receive(:dump).once
      subject.stash(case_map(1))
      subject.stash(case_map(2))
      subject.stash(case_map(3))
    end
  end

  describe '#dump' do
    it 'dumps to storage with metadata for the first time' do
      expect(storage).to receive(:dump).with(subject, exclude_metadata: false).once
      subject.dump
    end

    it 'dumps to storage without metadata for second+ time' do
      expect(storage).to receive(:dump).with(subject, exclude_metadata: false).once
      expect(storage).to receive(:dump).with(subject, exclude_metadata: true).once
      subject.dump
      subject.dump
    end
  end
end
