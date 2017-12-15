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
      subject.stash(case_map(1))
      expect(storage).to receive(:dump).with('file_spec.rb:1' => coverage, 'file_spec.rb:2' => coverage)
      subject.stash(case_map(2))

      subject.stash(case_map(3))
      expect(storage).to receive(:dump).with('file_spec.rb:3' => coverage)
      subject.dump
    end
  end
end
