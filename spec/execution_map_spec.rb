# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::ExecutionMap do
  subject { described_class.new }
  let(:affected_files) { instance_double(Array) }
  let(:case_map) { instance_double(Crystalball::CaseMap, uid: 'file_spec.rb:1', affected_files: affected_files) }

  before { allow(affected_files).to receive(:uniq) { affected_files } }

  describe '#<<' do
    it 'adds case to data' do
      expect do
        subject << case_map
      end.to change { subject.cases }.to('file_spec.rb:1' => affected_files)
    end
  end

  describe 'clear!' do
    it 'wipes out all cases' do
      subject << case_map
      expect do
        subject.clear!
      end.to change { subject.cases.size }.by(-1)
    end
  end

  context 'controls version compatibility' do
    subject { described_class.new(metadata: {version: version}, cases: cases) }
    let(:cases) { {'spec' => ['file']} }

    before do
      stub_const("#{described_class}::VERSION", 1.0)
    end

    context 'and passes for compatible version' do
      let(:version) { '1.5' }

      specify do
        expect { subject }.not_to raise_error(StandardError)
      end
    end

    context 'and works with specified version but without cases' do
      let(:version) { '1.5' }
      let(:cases) { {} }

      specify do
        expect { subject }.not_to raise_error(StandardError)
      end
    end

    context 'and raises for incompatible version' do
      let(:version) { '2.0' }

      specify do
        expect { subject }.to raise_error('Execution map incompatible version: 2.0. Expected: ~1.0')
      end
    end
  end
end
