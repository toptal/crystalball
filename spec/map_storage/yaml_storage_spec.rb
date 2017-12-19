# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapStorage::YAMLStorage do
  subject { described_class.new(path) }

  let(:path) { Pathname('map.yml') }

  def allow_path_exists(bool)
    allow(path).to receive(:exist?).with(no_args).and_return(bool)
  end

  describe '#clear!' do
    it 'does nothing when file does not exist' do
      allow_path_exists(false)
      subject.clear!
    end

    it 'deletes file when it exists' do
      allow_path_exists(true)
      expect(path).to receive(:delete).with(no_args)
      subject.clear!
    end
  end

  describe '#load' do
    let(:loaded_map) { subject.load }
    it 'loads yaml metadata and cases from file if it exists' do
      allow(path).to receive(:read).with(no_args).and_return({commit: '123', type: 'Crystalball::MapGenerator::SimpleMap'}.to_yaml + {'UID1' => %w[1 2 3]}.to_yaml + {'UID100' => %w[a b c]}.to_yaml)
      expect(loaded_map).to be_a Crystalball::MapGenerator::SimpleMap
      expect(loaded_map.cases).to eq('UID1' => %w[1 2 3], 'UID100' => %w[a b c])
      expect(loaded_map.commit).to eq '123'
    end
  end

  describe '#dump' do
    let(:map) { instance_double('Crystalball::MapGenerator::SimpleMap', to_h: {metadata: 'world', cases: 'hello'}) }
    let(:file) { instance_double(File) }

    before { allow(path).to receive(:open).with('a').and_yield(file) }
    it 'appends map to file' do
      expect(file).to receive(:write).with("--- world\n...\n")
      expect(file).to receive(:write).with("--- hello\n...\n")
      subject.dump(map)
    end

    context 'with exclude_metadata' do
      it "doesn't write any metadata object" do
        expect(file).not_to receive(:write).with("--- world\n...\n")
        expect(file).to receive(:write).with("--- hello\n...\n")
        subject.dump(map, exclude_metadata: true)
      end
    end
  end
end
