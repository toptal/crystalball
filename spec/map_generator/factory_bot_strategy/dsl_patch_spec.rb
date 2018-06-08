# frozen_string_literal: true

require 'spec_helper'
require 'crystalball/factory_bot'

describe Crystalball::MapGenerator::FactoryBotStrategy::DSLPatch do
  subject(:instance) do
    Class.new do
      def factory(*args, &block)
        [*args, block]
      end

      prepend Crystalball::MapGenerator::FactoryBotStrategy::DSLPatch
    end.new
  end

  before do
    class_double('FactoryBotConstant').as_stubbed_const
    allow(Crystalball::MapGenerator::FactoryBotStrategy).to receive(:factory_bot_constant).and_return(FactoryBotConstant)
  end

  dsl_klasses = %w[DSL ModifyDSL].map { |name| '::FactoryBotConstant::Syntax::Default::' + name }

  dsl_klasses.each do |dsl_klass|
    context "#{dsl_klass} patching" do
      let!(:patched_class) do
        stub_const(
          dsl_klass,
          Class.new do
            def factory(*); end
          end
        )
      end

      before do
        second_dsl_klass = (dsl_klasses - [dsl_klass]).first
        stub_const(
          second_dsl_klass,
          Class.new do
            def factory(*); end
          end
        )
      end

      it 'changes and restores factory method' do
        original_factory = patched_class.instance_method(:factory)
        described_class.apply!
        expect(patched_class.instance_method(:factory)).not_to eq original_factory
      end
    end

    describe '#factory' do
      subject { instance.factory(:dummy, &block) }
      let(:block) { -> {} }
      let(:factory_definitions) { {} }

      before do
        allow(Crystalball::MapGenerator::FactoryBotStrategy).to receive(:factory_definitions).and_return(factory_definitions)
        allow(Crystalball::MapGenerator::FactoryBotStrategy::DSLPatch::FactoryPathFetcher).to receive(:fetch).and_return('/factories/file.rb')
      end

      it do
        expect { subject }.to change { factory_definitions }.from({}).to('dummy' => ['/factories/file.rb'])
        is_expected.to eq([:dummy, block])
      end
    end
  end
end
