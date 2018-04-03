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
      allow(::RSpec).to receive(:configure).and_yield(rspec_configuration)
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
  let(:map_class) { configuration.map_class }
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
          allow(Crystalball::GitRepo).to receive(:exists?).with(Pathname('.')).and_return(false)
        end

        it { is_expected.to be_nil }
      end
    end
  end

  context 'configured' do
    let(:dummy_strategy) do
      double.as_null_object.tap do |s|
        def s.call(case_map, _example)
          yield case_map
        end
      end
    end

    before do
      configuration.commit = 'abc'
      configuration.dump_threshold = threshold
      configuration.map_storage = storage
      configuration.register dummy_strategy
      configuration.version = 1.0
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
        expect(storage).to receive(:dump).with(type: map_class.to_s, commit: 'abc', version: 1.0)
        subject.start!
      end

      it 'fails if repo is not pristine' do
        allow_any_instance_of(Crystalball::GitRepo).to receive(:pristine?).and_return(false)

        expect { subject.start! }.to raise_error(StandardError, 'Repository is not pristine! Please stash all your changes')
      end

      it 'calls after_start for each registered strategy' do
        expect(dummy_strategy).to receive(:after_start).once
        subject.start!
      end
    end

    describe '#map' do
      it 'sets proper commit SHA for the map' do
        allow_any_instance_of(Git::Base).to receive(:object).with('HEAD').and_return(double(sha: 'abc'))

        expect(subject.map.commit).to eq 'abc'
      end
    end

    describe '#finalize!' do
      let(:started) { true }

      before { allow(subject).to receive(:started) { started } }

      context 'with empty map' do
        it 'does nothing' do
          expect(storage).not_to receive(:dump)
          subject.finalize!
        end
      end

      it 'dumps the map' do
        allow_any_instance_of(map_class).to receive(:size).and_return(10)
        expect(storage).to receive(:dump).with({})
        subject.finalize!
      end

      it 'calls before_finalize for each registered strategy' do
        expect(dummy_strategy).to receive(:before_finalize).once
        subject.finalize!
      end

      context 'when generator not started' do
        let(:started) { false }

        it 'does nothing' do
          expect(dummy_strategy).not_to receive(:before_finalize)
          expect(storage).not_to receive(:dump)
          subject.finalize!
        end
      end
    end

    describe '#refresh_for_case' do
      def rspec_example(id = '1')
        double(run: true, id: id, file_path: '1.rb')
      end

      def example_map(uid)
        instance_double('Crystalball::CaseMap', uid: uid, affected_files: [])
      end

      it 'runs the example' do
        allow(configuration.strategies).to receive(:run).and_call_original
        ex = rspec_example
        expect(ex).to receive(:run)
        subject.refresh_for_case(ex)
      end

      it 'adds execution map for given case' do
        rspec_case = rspec_example
        allow(configuration.strategies).to receive(:run).with(kind_of(Crystalball::CaseMap), rspec_case)
                                                        .and_return(example_map('1'))
        expect do
          subject.refresh_for_case(rspec_case)
        end.to change { subject.map.size }.by(1)
      end

      context 'with threshold' do
        let(:threshold) { 2 }

        it 'dumps map cases and clears the map if map size is over threshold' do
          allow(configuration.strategies).to receive(:run).with(kind_of(Crystalball::CaseMap), any_args)
                                                          .and_return(example_map('1'), example_map('2'), example_map('3'))

          expect(storage).to receive(:dump).with('1' => [], '2' => []).once
          expect_any_instance_of(map_class).to receive(:clear!).once.and_call_original
          subject.refresh_for_case(rspec_example('1'))
          subject.refresh_for_case(rspec_example('2'))
          subject.refresh_for_case(rspec_example('3'))
        end
      end
    end
  end
end
