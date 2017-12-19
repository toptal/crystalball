# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator do
  describe '.build' do
    it 'is alias to new' do
      config = {execution_detector: nil, map_storage: nil, dump_threshold: 1}
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
                        map_storage: storage,
                        dump_threshold: 100)
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
                        map_storage: storage,
                        dump_threshold: threshold)
  end
  let(:threshold) { 0 }
  let(:detector) { instance_double('Crystalball::ExecutionDetector') }
  let(:storage) { instance_double('Crystalball::MapStorage::YAMLStorage', clear!: true, dump: true) }

  describe '#start!' do
    before do
      allow_any_instance_of(Crystalball::GitRepo).to receive(:pristine?).and_return(true)
      allow_any_instance_of(Git::Base).to receive(:object).with('HEAD').and_return(double(sha: 'abc'))
    end

    it 'wipes the map and clears storage' do
      expect(storage).to receive :clear!
      expect do
        subject.start!
      end.to(change { subject.map.object_id })
    end

    it 'dump new map metadata to storage' do
      expect(storage).to receive(:dump).with(type: 'Crystalball::ExecutionMap', commit: 'abc')
      subject.start!
    end

    it 'fails if repo is not pristine' do
      allow_any_instance_of(Crystalball::GitRepo).to receive(:pristine?).and_return(false)

      expect { subject.start! }.to raise_error(StandardError, 'Repository is not pristine! Please stash all your changes')
    end
  end

  describe '#map' do
    it 'sets proper commit SHA for the map' do
      allow_any_instance_of(Git::Base).to receive(:object).with('HEAD').and_return(double(sha: 'abc'))

      expect(subject.map.commit).to eq 'abc'
    end
  end

  describe '#finalize!' do
    context 'with empty map' do
      it 'does nothing' do
        expect(storage).not_to receive(:dump)
        subject.finalize!
      end
    end

    it 'dumps the map' do
      allow_any_instance_of(Crystalball::ExecutionMap).to receive(:size).and_return(10)
      expect(storage).to receive(:dump).with({})
      subject.finalize!
    end
  end

  describe '#refresh_for_case' do
    def rspec_example(uid = '1')
      double(run: true, location_rerun_argument: uid)
    end

    let(:example_map) { {} }

    before do
      before = double
      after = double
      allow(Coverage).to receive(:peek_result).and_return(before, after)
      allow(detector).to receive(:detect).with(before, after).and_return(example_map)
    end

    it 'adds execution map for given case' do
      rspec_case = rspec_example
      allow(Crystalball::CaseMap)
        .to receive(:new)
        .with(rspec_case, example_map)
        .and_return(instance_double('Crystalball::CaseMap', case_uid: '5', coverage: []))
      expect do
        subject.refresh_for_case(rspec_case)
      end.to change { subject.map.size }.by(1)
    end

    context 'with threshold' do
      let(:threshold) { 2 }

      before do
        allow(detector).to receive(:detect).and_return(example_map)
      end

      it 'dumps map cases and clears the map if map size is over threshold' do
        expect(storage).to receive(:dump).with('1' => {}, '2' => {}).once
        expect_any_instance_of(Crystalball::ExecutionMap).to receive(:clear!).once.and_call_original
        subject.refresh_for_case(rspec_example('1'))
        subject.refresh_for_case(rspec_example('2'))
        subject.refresh_for_case(rspec_example('3'))
      end
    end
  end
end
