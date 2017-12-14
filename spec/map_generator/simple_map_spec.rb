# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator::SimpleMap do
  subject { described_class.new(storage) }
  let(:storage) { instance_double(Crystalball::MapStorage::YAMLStorage) }
  let(:coverage) { double }
  let(:case_map) { instance_double(Crystalball::CaseMap, case_uid: 'file_spec.rb:1', coverage: coverage) }

  def expect_data(data)
    expect(storage).to receive(:dump).with(data)
    subject.dump
  end

  describe '#load' do
    it 'loads map from storage' do
      expect(storage).to receive(:load).and_return(data = double)
      subject.load
      expect_data(data)
    end
  end

  describe '#stash' do
    it 'adds case to data' do
      subject.stash(case_map)
      expect_data('file_spec.rb:1' => coverage)
    end
  end

  describe '#clear!' do
    it 'removes cases from map' do
      subject.stash(case_map)
      subject.clear!
      expect_data({})
    end
  end
end
