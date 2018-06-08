# frozen_string_literal: true

require 'spec_helper'
require 'crystalball/factory_bot'

describe Crystalball::MapGenerator::FactoryBotStrategy::DSLPatch::FactoryPathFetcher do
  describe '.fetch' do
    subject { described_class.fetch }

    before do
      class_double('FactoryBotConstant', definition_file_paths: %w[/factories/]).as_stubbed_const
      allow(Crystalball::MapGenerator::FactoryBotStrategy).to receive(:factory_bot_constant).and_return(FactoryBotConstant)
      allow(described_class).to receive(:caller).and_return([
                                                              '/even/there/is/something.rb:998:in somewhere',
                                                              '/factories/file.rb:12:in will',
                                                              '/be/determinated.rb:45:in properly'
                                                            ])
    end

    it { is_expected.to eq '/factories/file.rb' }
  end
end
