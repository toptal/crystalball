# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator do
  describe '.start' do
    subject { described_class.start! }
    let(:generator) { described_class.new }
    let(:rspec_configuration) { spy }

    before do
      allow(Coverage).to receive(:start)
      allow(described_class).to receive(:new).and_return(generator)
      allow(RSpec).to receive(:configure).and_yield(rspec_configuration)
    end

    it 'starts code coverage' do
      subject
      expect(Coverage).to have_received(:start)
    end

    it 'yields configuration' do
      yielded_args = nil
      described_class.start! { |*args| yielded_args = args }
      expect(yielded_args).to eq([generator.configuration])
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

  subject(:generator) { described_class.new }
  let(:configuration) { generator.configuration }
  let(:threshold) { 0 }
  let(:detector) { instance_double('Crystalball::ExecutionDetector') }
  let(:storage) { instance_double('Crystalball::MapStorage::YAMLStorage', clear!: true, dump: true) }

  describe '#configuration' do
    describe '.commit' do
      subject { configuration.commit }
      it 'is git repo HEAD by default' do
        allow_any_instance_of(Git::Base).to receive(:object).with('HEAD').and_return(double(sha: 'abc'))
        expect(subject).to eq 'abc'
      end

      context 'when repo does not exist' do
        before do
          allow(Crystalball::GitRepo).to receive(:exists?).with('.').and_return(false)
        end

        it { is_expected.to be_nil }
      end
    end
  end

  context 'configured' do
    before do
      configuration.commit = 'abc'
      configuration.dump_threshold = threshold
      configuration.execution_detector = detector
      configuration.map_storage = storage
    end

    describe '#start!' do
      before do
        allow_any_instance_of(Crystalball::GitRepo).to receive(:pristine?).and_return(true)
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
        double(run: true, id: uid)
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
          .and_return(instance_double('Crystalball::CaseMap', uid: '5', coverage: []))
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
end
