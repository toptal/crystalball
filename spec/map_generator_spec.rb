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
  let(:storage) { instance_double('Crystalball::MapStorage::YAMLStorage', clear!: true, dump: true, dump_metadata: true) }

  describe '#configuration' do
    describe '.commit' do
      subject { configuration.commit }
      let(:commit) { double }

      it 'is git repo HEAD by default' do
        allow_any_instance_of(Git::Base).to receive(:gcommit).with('HEAD').and_return(commit)
        expect(subject).to eq commit
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
        def s.call(example_group_map, _example)
          yield example_group_map
        end
      end
    end

    before do
      configuration.commit = double(sha: 'abc', date: 1234)
      configuration.dump_threshold = threshold
      configuration.map_storage = storage
      configuration.register dummy_strategy
      configuration.version = 1.0
      configuration.compact_map = false
    end

    describe '#start!' do
      it 'wipes the map and clears storage' do
        expect(storage).to receive :clear!
        subject.start!
      end

      it 'dump new map metadata to storage' do
        expect(storage).to receive(:dump_metadata).with(type: map_class.to_s, commit: 'abc', timestamp: 1234, version: 1.0)
        subject.start!
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

      context 'when compacting enabled' do
        it 'compacts the map before dumping' do
          allow_any_instance_of(map_class).to receive(:size).and_return(10)
          configuration.compact_map = true
          allow(Crystalball::MapCompactor).to receive(:compact_map!).and_return(double(example_groups: 'example_groups'))
          expect(storage).to receive(:dump).with('example_groups')
          subject.finalize!
        end
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
        instance_double('Crystalball::ExampleGroupMap', uid: uid, used_files: [])
      end

      it 'runs the example' do
        allow(configuration.strategies).to receive(:run).and_call_original
        ex = rspec_example
        expect(ex).to receive(:run)
        subject.refresh_for_case(ex)
      end

      it 'adds execution map for given case' do
        rspec_case = rspec_example
        allow(configuration.strategies).to receive(:run).with(kind_of(Crystalball::ExampleGroupMap), rspec_case)
                                                        .and_return(example_map('1'))
        expect do
          subject.refresh_for_case(rspec_case)
        end.to change { subject.map.size }.by(1)
      end

      context 'with threshold' do
        let(:threshold) { 2 }

        it 'dumps map example_groups and clears the map if map size is over threshold' do
          allow(configuration.strategies).to receive(:run).with(kind_of(Crystalball::ExampleGroupMap), any_args)
                                                          .and_return(example_map('1'), example_map('2'), example_map('3'))

          expect(storage).to receive(:dump).with('1' => [], '2' => []).once
          expect_any_instance_of(map_class).to receive(:clear!).once.and_call_original
          subject.refresh_for_case(rspec_example('1'))
          subject.refresh_for_case(rspec_example('2'))
          subject.refresh_for_case(rspec_example('3'))
        end

        context 'with compacting' do
          before { configuration.compact_map = true }

          it 'does nothing' do
            expect(storage).not_to receive(:dump)
            subject.refresh_for_case(rspec_example('1'))
            subject.refresh_for_case(rspec_example('2'))
            subject.refresh_for_case(rspec_example('3'))
          end
        end
      end
    end
  end
end
