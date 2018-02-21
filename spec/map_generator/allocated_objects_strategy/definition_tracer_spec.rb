# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator::AllocatedObjectsStrategy::DefinitionTracer do
  subject(:tracer) { described_class.new }

  let(:trace_point) { instance_double('TracePoint', enable: true) }

  describe '#start' do
    subject { tracer.start }

    it 'enable TracePoint' do
      expect(TracePoint).to receive(:new).with(:class) { trace_point }
      subject
    end

    context 'tracepoint block' do
      let(:trace_point) { instance_double('TracePoint', enable: nil, path: path, binding: binding) }
      let(:binding) { instance_double('Binding') }

      before do
        allow(TracePoint).to receive(:new).with(:class) { trace_point }.and_yield(trace_point)
        allow(binding).to receive(:eval).with('name') { name }
      end

      context 'stores constant with path and name' do
        let(:path) { 'some/dummy.rb' }
        let(:name) { 'Dummy' }
        let(:another_trace_point) { instance_double('TracePoint', enable: nil, path: another_path, binding: binding) }
        let(:another_path) { 'another/dummy.rb' }

        before do
          allow(TracePoint).to receive(:new).with(:class) { trace_point }.and_yield(trace_point).and_yield(another_trace_point)
        end

        specify do
          subject
          expect(tracer.constants_definition_paths).to eq('Dummy' => [path, another_path])
        end
      end

      context 'skips constant without path' do
        let(:path) { nil }
        let(:name) { 'Dummy' }

        specify do
          subject
          expect(tracer.constants_definition_paths).to be_empty
        end
      end

      context 'skips constant without name' do
        let(:path) { 'some/dummy.rb' }
        let(:name) { nil }

        specify do
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
