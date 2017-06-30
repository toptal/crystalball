require 'spec_helper'
require 'crystalball/map_storage/yaml_storage'

describe Crystalball::MapStorage::YAMLStorage do
  let(:output)       { StringIO.new }
  let(:target_file)  { 'execution_map.yml' }

  subject { described_class.new(target_file) }

  context 'saving' do
    before {
      allow(File).to receive(:open).with(target_file, 'a').and_yield(output)
    }

    it 'should generate dumps' do
      subject.dump('a' => 1)
      expect(output.string).to eq("a: 1\n")
      subject.dump('b' => 2)
      expect(output.string).to eq("a: 1\nb: 2\n")
    end
  end

  context 'reading' do
    before {
      allow(File).to receive(:exists?).with(target_file).and_return(true)
      allow(File).to receive(:read).with(target_file).and_return("a: 1\nb: 2\n")
    }

    it 'should load dumps' do
      expect(subject.load).to eq('a' => 1, 'b' => 2)
    end
  end
end
