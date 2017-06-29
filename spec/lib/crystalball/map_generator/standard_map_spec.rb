require 'spec_helper'

RSpec.describe Crystalball::MapGenerator::StandardMap do
  let(:map) { described_class.new(storage) }
  let(:storage) { instance_double(Crystalball::MapStorage::YAMLStorage) }

  describe '#stash' do
    let(:case_map) { double(case_uid: 'bar', coverage: 'foo') }
    subject(:stash) { map.stash(case_map) }

    it 'dumps the case map to the raw map' do
      expect(map.raw_map).to eq({})
      stash
      expect(map.raw_map).to include('bar' => 'foo')
    end

    context 'when the raw map size exceeds threshold' do
      let(:map) { described_class.new(storage, dump_threshold: 2) }
      let(:another_case_map) { double(case_uid: 'something', coverage: 'else') }

      before do
        stash
      end

      it 'dumps the map to the file' do
        expect(storage).to receive(:dump)
          .with('bar' => 'foo', 'something' => 'else')

        map.stash(another_case_map)
      end

      it 'clears the raw map' do
        allow(storage).to receive(:dump)
          .with('bar' => 'foo', 'something' => 'else')

        map.stash(another_case_map)

        expect(map.raw_map).to eq({})
      end
    end
  end
end
