# frozen_string_literal: true

require 'spec_helper'
require 'graphql'
require 'crystalball/graphql'

describe Crystalball::GraphQL::MapGenerator::GraphQLStrategy do
  subject(:strategy) { described_class.new }

  before do
    stub_const('GraphQL::Schema', Class.new)
  end

  include_examples 'base strategy'

  describe '#after_register' do
    subject { strategy.after_register }

    it 'enables the tracer' do
      expect_any_instance_of(TracePoint)
        .to receive(:enable)
      subject
    end
  end

  describe '#before_finalize' do
    subject { strategy.before_finalize }

    it 'disables the tracer' do
      expect_any_instance_of(TracePoint)
        .to receive(:disable)
      subject
    end
  end

  describe '.apply_patch!' do
    subject(:apply!) { described_class.apply_patch! }

    before do
      allow(described_class).to receive(:apply_patch).and_return(apply_patch_return)
    end

    context 'when apply_patch succeeds' do
      let(:apply_patch_return) { true }

      it 'does not raise error' do
        expect { apply! }.not_to raise_error
      end
    end

    context 'when apply_patch fails' do
      let(:apply_patch_return) { nil }

      it 'raises error' do
        expect { apply! }.to raise_error(NameError)
      end
    end
  end

  describe '#call' do
    let(:case_map) { [] }

    context 'when the schema is executed' do
      let(:schema) { Class.new }

      before do
        allow(described_class).to receive(:type_definition_paths)
          .and_return(schema.object_id => %w[foo bar])
        allow(described_class).to receive(:current_schema).and_return(schema)
      end

      it 'pushes affected files to case map' do
        expect do
          subject.call(case_map, 'example') do
            # NOOP, #schema_executed? was stubbed
          end
        end.to change { case_map }.to %w[foo bar]
      end
    end

    context 'when the schema is not executed' do
      before do
        described_class.type_definition_paths = {}
        allow(described_class).to receive(:current_schema).and_return(nil)
      end

      it 'does nothing with case map' do
        expect do
          subject.call(case_map, 'example') do
            # NOOP, #schema_executed? was stubbed
          end
        end.not_to(change { case_map })
      end
    end

    it 'yields case_map to a block' do
      allow(strategy).to receive(:filter).with([]).and_return([])

      expect do |b|
        subject.call(case_map, 'example', &b)
      end.to yield_with_args(case_map)
    end
  end
end
