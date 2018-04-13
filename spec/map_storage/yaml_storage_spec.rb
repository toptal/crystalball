# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapStorage::YAMLStorage do
  subject { described_class.new(path) }

  let(:path) { Pathname('map.yml') }

  def allow_path_exists(bool)
    allow(path).to receive(:exist?).with(no_args).and_return(bool)
  end

  describe '.load' do
    subject(:map) { described_class.load(path) }

    it 'loads yaml metadata and cases from file if it exists' do
      allow_path_exists true
      allow(path).to receive(:read).with(no_args).and_return({commit: '123', type: 'Crystalball::ExecutionMap'}.to_yaml + {'UID1' => %w[1 2 3]}.to_yaml + {'UID100' => %w[a b c]}.to_yaml)
      expect(map).to be_a Crystalball::ExecutionMap
      expect(map.cases).to eq('UID1' => %w[1 2 3], 'UID100' => %w[a b c])
      expect(map.commit).to eq '123'
    end

    context 'when path is a directory' do
      let(:path) { instance_double('Pathname', directory?: true) }
      let(:file1) { instance_double('Pathname', file?: true, exist?: true, read: file_content1) }
      let(:file_content1) do
        {commit: '123', type: 'Crystalball::ExecutionMap'}.to_yaml + {'UID1' => %w[1 2 3]}.to_yaml
      end
      let(:file2) { instance_double('Pathname', file?: true, exist?: true, read: file_content2) }
      let(:file_content2) do
        {commit: '123', type: 'Crystalball::ExecutionMap'}.to_yaml + {'UID100' => %w[a b c]}.to_yaml
      end
      let(:subdir) { instance_double('Pathname', directory?: true, file?: false) }

      before do
        allow_path_exists true
        allow(path).to receive(:each_child).and_return [file1, file2, subdir]
      end

      it 'load every file in directory' do
        expect(map).to be_a Crystalball::ExecutionMap
        expect(map.cases).to eq('UID1' => %w[1 2 3], 'UID100' => %w[a b c])
        expect(map.commit).to eq '123'
      end

      context 'when metadata info is inconsistent' do
        let(:file_content2) do
          {commit: '456', type: 'Crystalball::ExecutionMap'}.to_yaml + {'UID100' => %w[a b c]}.to_yaml
        end

        specify do
          expect { subject }.to raise_error("Can't load execution maps with different metadata. Metadata: [{:commit=>\"123\", :type=>\"Crystalball::ExecutionMap\"}, {:commit=>\"456\", :type=>\"Crystalball::ExecutionMap\"}]")
        end
      end
    end

    context 'when path is empty' do
      let(:path) { instance_double('Pathname', directory?: false, exist?: false) }

      it 'fails with NoFilesFoundError' do
        expect { map }.to raise_error Crystalball::MapStorage::NoFilesFoundError
      end

      context 'and is a directory' do
        let(:path) { instance_double('Pathname', directory?: true, each_child: []) }
        it 'fails with NoFilesFoundError' do
          expect { map }.to raise_error Crystalball::MapStorage::NoFilesFoundError
        end
      end
    end
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

  describe '#dump' do
    let(:data) { {'metadata' => 'world', 'cases' => 'hello'} }
    let(:file) { instance_double(File) }

    before { allow(path).to receive(:open).with('a').and_yield(file) }
    it 'appends map to file' do
      expect(file).to receive(:write).with("---\nmetadata: world\ncases: hello\n")
      subject.dump(data)
    end
  end
end
