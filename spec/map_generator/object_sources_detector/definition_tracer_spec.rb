# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator::ObjectSourcesDetector::DefinitionTracer do
  subject(:tracer) { described_class.new(root_path) }

  let(:trace_point) { instance_double('TracePoint', enable: true) }
  let(:root_path) { '/some' }

  describe '#start' do
    subject { tracer.start }

    it 'enable TracePoint' do
      expect(TracePoint).to receive(:new).with(:class) { trace_point }
      subject
    end

    context 'with block' do
      let(:trace_point) { instance_double('TracePoint', enable: nil, path: path, binding: binding) }
      let(:binding) { instance_double('Binding') }

      before do
        stub_const('Dummy', Class.new)
        allow(TracePoint).to receive(:new).with(:class) { trace_point }.and_yield(trace_point)
        allow(binding).to receive(:eval).with('self') { Dummy }
      end

      context 'which stores' do
        let(:path) { '/some/dummy.rb' }
        let(:another_trace_point) { instance_double('TracePoint', enable: nil, path: another_path, binding: binding) }
        let(:another_path) { '/another/dummy.rb' }

        before do
          allow(TracePoint).to receive(:new).with(:class) { trace_point }.and_yield(trace_point).and_yield(another_trace_point)
        end

        it 'constant with path in root' do
          subject
          expect(tracer.constants_definition_paths).to eq(Dummy => [path])
        end
      end

      context 'which skips' do
        let(:path) { nil }

        it 'constant without path' do
          subject
          expect(tracer.constants_definition_paths).to be_empty
        end
      end
    end
  end

  describe '#stop' do
    subject { tracer.stop }

    it 'disable TracePoint' do
      allow(tracer).to receive(:trace_point) { trace_point }
      expect(trace_point).to receive(:disable)
      subject
    end
  end
end
