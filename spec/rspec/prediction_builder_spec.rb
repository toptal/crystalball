# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::RSpec::PredictionBuilder do
  subject(:builder) { described_class.new(Crystalball::RSpec::Runner::Configuration.new(configuration)) }
  let(:configuration) { {'repo_path' => 'test'} }

  let(:map) { instance_double('Crystalball::ExecutionMap') }
  let(:repo) { double }

  before do
    allow(Crystalball::MapStorage::YAMLStorage).to receive(:load).with(Pathname('tmp/execution_map.yml')).and_return(map)
    allow(Crystalball::GitRepo).to receive(:open).with(Pathname('test')).and_return(repo)
  end

  describe '#repo' do
    it 'opens a GitRepo with the given path' do
      expect(Crystalball::GitRepo).to receive(:open).with(Pathname('test'))
      builder.repo
    end
  end

  describe '#prediction' do
    let(:configuration) do
      super().merge(
        'diff_from' => 'HEAD~3',
        'diff_to' => 'HEAD'
      )
    end
    it 'raises NotImplementedError by default' do
      expect { builder.prediction }.to raise_error NotImplementedError
    end
  end

  describe '#expired_map?' do
    subject { builder.expired_map? }
    context 'when expiration configuration is <= 0' do
      let(:configuration) do
        super().merge('map_expiration_period' => 0)
      end

      it { is_expected.to eq false }
    end

    context 'when expiration configuration is > 0', freeze: true do
      let(:configuration) do
        super().merge('map_expiration_period' => 10)
      end
      let(:commit_date) { Time.now - 5 }
      let(:commit_info) { double(date: commit_date) }
      let(:map_commit) { double }

      before { allow(map).to receive(:commit).and_return(map_commit) }

      context 'when commit exists in the working tree' do
        before do
          allow(repo).to receive(:gcommit!).with(map_commit).and_return(commit_info)
        end

        context 'and map commit is too old' do
          let(:commit_date) { Time.now - 10 }

          it { is_expected.to eq true }
        end

        context 'and map commit is fresh enough' do
          let(:commit_date) { Time.now - 9 }

          it { is_expected.to eq false }
        end
      end

      context 'when map commit doesnt exist in the working tree' do
        it 'tries to fetch repo remotes' do
          allow(repo).to receive(:gcommit!).with(map_commit).and_return(nil, commit_info)
          expect(repo).to receive(:fetch).once.and_return(true)
          expect(subject).to eq false
        end
      end
    end
  end
end
