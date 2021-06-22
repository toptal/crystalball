# frozen_string_literal: true

require 'spec_helper'
require 'crystalball/factory_bot'

describe Crystalball::MapGenerator::FactoryBotStrategy::FactoryRunnerPatch do
  subject(:instance) do
    Class.new do
      prepend Crystalball::MapGenerator::FactoryBotStrategy::FactoryRunnerPatch

      def run(*args, &block)
        [*args, block]
      end
    end.new
  end

  before do
    class_double('FactoryBotConstant').as_stubbed_const
    allow(Crystalball::MapGenerator::FactoryBotStrategy).to receive(:factory_bot_constant).and_return(FactoryBotConstant)
  end

  context 'FactoryBotConstant::FactoryRunner patching' do
    let!(:patched_class) do
      stub_const(
        '::FactoryBotConstant::FactoryRunner',
        Class.new do
          def run(*); end
        end
      )
    end

    it 'changes run method' do
      original_run = patched_class.instance_method(:run)
      described_class.apply!
      expect(patched_class.instance_method(:run)).not_to eq original_run
    end
  end

  describe '#run' do
    subject { instance.run('args', &block) }
    let(:block) { -> {} }
    let(:used_factories) { [] }

    before do
      allow(Crystalball::MapGenerator::FactoryBotStrategy).to receive(:used_factories).and_return(used_factories)
      allow(FactoryBotConstant).to receive_message_chain(:factories, :find).with(:bad_dummy) { double(name: :dummy) }
      instance.instance_variable_set(:@name, :bad_dummy)
    end

    it do
      expect { subject }.to change { used_factories }.from([]).to(%w[dummy])
      is_expected.to eq(['args', block])
    end
  end
end
