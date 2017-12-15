# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator do
  describe '.build' do
    it 'is alias to new' do
      config = {execution_detector: nil, map_class: nil, map_storage: nil}
      expect(described_class).to receive(:new).with(config)

      described_class.build(config)
    end
  end

  describe '.default_config' do
    subject { described_class.default_config }
    let(:detector) { instance_double('Crystalball::ExecutionDetector') }
    let(:storage) { instance_double('Crystalball::MapStorage::YAMLStorage') }

    before do
      allow(Crystalball::ExecutionDetector)
        .to receive(:new).with(Dir.pwd).and_return detector
      allow(Crystalball::MapStorage::YAMLStorage)
        .to receive(:new).with(Pathname('execution_map.yml')).and_return storage
    end

    it do
      is_expected.to eq(execution_detector: detector,
                        map_class: Crystalball::MapGenerator::StandardMap,
                        map_storage: storage)
    end
  end

  describe '.start' do
    subject { described_class.start! }
    let(:generator) { instance_double(described_class) }
    let(:rspec_configuration) { spy }

    before do
      allow(Coverage).to receive(:start)
      allow(described_class).to receive(:build).and_return(generator)
      allow(RSpec).to receive(:configure).and_yield(rspec_configuration)
    end

    it 'starts code coverage' do
      subject
      expect(Coverage).to have_received(:start)
    end

    it 'sets before suite callback' do
      expect(generator).to receive(:start!)
      expect(rspec_configuration).to receive(:before).with(:suite).and_yield
      subject
    end

    it 'sets around example callback' do
      expect(generator).to receive(:refresh_for_case).with(example = double)
      expect(rspec_configuration).to receive(:around).with(:each).and_yield(example)
      subject
    end

    it 'sets after suite callback' do
      expect(generator).to receive(:finalize!)
      expect(rspec_configuration).to receive(:after).with(:suite).and_yield
      subject
    end
  end

  subject do
    described_class.new(execution_detector: detector,
                        map_class: Crystalball::MapGenerator::StandardMap,
                        map_storage: storage)
  end
  let(:detector) { instance_double('Crystalball::ExecutionDetector') }
  let(:storage) { instance_double('Crystalball::MapStorage::YAMLStorage', clear!: true) }

  describe '#start!' do
    before do
      allow_any_instance_of(Crystalball::GitRepo).to receive(:pristine?).and_return(true)
    end

    it 'wipes the map and clears storage' do
      allow_any_instance_of(Git::Base).to receive(:object).with('HEAD').and_return(double(sha: 'abc'))

      expect(storage).to receive :clear!
      expect do
        subject.start!
      end.to(change { subject.map.object_id })
    end

    it 'fails if repo is not pristine' do
      allow_any_instance_of(Crystalball::GitRepo).to receive(:pristine?).and_return(false)

      expect { subject.start! }.to raise_error(StandardError, 'Repository is not pristine! Please stash all your changes')
    end
  end

  describe '#finalize!' do
    it 'dumps the map' do
      expect(subject.map).to receive(:dump)
      subject.finalize!
    end
  end

  describe '#refresh_for_case' do
    let(:rspec_example) { double(run: true) }
    let(:case_map) { instance_double('Crystalball::CaseMap') }

    before do
      before = double
      after = double
      allow(Coverage).to receive(:peek_result).and_return(before, after)

      example_map = {}
      allow(detector).to receive(:detect).with(before, after).and_return(example_map)
      allow(Crystalball::CaseMap).to receive(:new).with(rspec_example, example_map).and_return(case_map)
    end

    it 'stashes execution map for given case' do
      expect(subject.map).to receive(:stash).with(case_map)
      subject.refresh_for_case(rspec_example)
    end
  end
end
