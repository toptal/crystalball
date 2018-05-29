# frozen_string_literal: true

require 'rails_helper'

describe Crystalball::Rails::TablesMapGenerator do
  describe '.start' do
    subject { described_class.start! }
    let(:generator) { described_class.new }
    let(:rspec_configuration) { spy }
    let(:object_sources_detector) { spy }

    before do
      allow_any_instance_of(Crystalball::Rails::TablesMapGenerator::Configuration).to receive(:object_sources_detector) { object_sources_detector }
      allow(described_class).to receive(:new).and_return(generator)
      allow(RSpec).to receive(:configure).and_yield(rspec_configuration)
    end

    it 'sets before suite callback' do
      expect(generator).to receive(:start!)
      expect(rspec_configuration).to receive(:before).with(:suite).and_yield
      subject
    end

    it 'sets after suite callback' do
      expect(generator).to receive(:finalize!)
      expect(rspec_configuration).to receive(:after).with(:suite).and_yield
      subject
    end

    it 'runs object_sources_detector after_register' do
      subject
      expect(object_sources_detector).to have_received(:after_register)
    end
  end

  subject(:generator) { described_class.new }
  let(:configuration) { generator.configuration }
  let(:map_class) { Crystalball::Rails::TablesMap }
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
    before do
      configuration.commit = 'abc'
      configuration.map_storage = storage
      configuration.version = 1.0

      stub_const('::ActiveRecord::Base', double(table_name: nil, descendants: []))
    end

    describe '#start!' do
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

      context 'dumps the map' do
        let(:descendant) { double(table_name: 'Dummy') }

        before do
          allow(ActiveRecord::Base).to receive(:descendants).and_return [descendant]
          allow(subject.object_sources_detector).to receive(:detect).with([descendant]) { ['file1'] }
        end

        specify do
          expect(storage).to receive(:dump).with('Dummy' => ['file1'])
          subject.finalize!
        end
      end

      context 'with empty map' do
        it 'does nothing' do
          expect(storage).not_to receive(:dump)
          subject.finalize!
        end
      end

      context 'when generator not started' do
        let(:started) { false }

        it 'does nothing' do
          expect(storage).not_to receive(:dump)
          subject.finalize!
        end
      end
    end
  end
end
