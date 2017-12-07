# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapStorage::YAMLStorage do
  subject { described_class.new(path) }

  let(:path) { Pathname('map.yml') }

  def expect_path_exists(bool)
    expect(path).to receive(:exist?).with(no_args).and_return(bool)
  end

  describe '#clear!' do
    it 'does nothing when file does not exist' do
      expect_path_exists(false)
      subject.clear!
    end

    it 'deletes file when it exists' do
      expect_path_exists(true)
      expect(path).to receive(:delete).with(no_args)
      subject.clear!
    end
  end

  describe '#load' do
    it 'does nothing when file does not exist' do
      expect_path_exists(false)
      subject.load
    end

    it 'loads yaml from file if it exists' do
      expect_path_exists(true)
      expect(path).to receive(:read).with(no_args).and_return({ 'hello' => 'world' }.to_yaml)
      expect(subject.load).to eq('hello' => 'world')
    end
  end

  describe '#dump' do
    it 'appends map to file' do
      expect(path).to receive(:open).with('a').and_yield(file = instance_double(File))
      expect(file).to receive(:write).with("---\nhello: world\n")
      subject.dump('hello' => 'world')
    end
  end
end
