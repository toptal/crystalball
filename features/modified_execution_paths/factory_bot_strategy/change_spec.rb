# frozen_string_literal: true

require_relative '../../feature_helper'

describe 'Changing source file' do
  include_context 'simple git repository'
  include_context 'base forecast'

  let(:strategies) do
    [Crystalball::Predictor::ModifiedExecutionPaths.new]
  end

  context 'when dealing with factories' do
    map_generator_config do
      <<~CONFIG
        Crystalball::MapGenerator.start! do |c|
          c.register Crystalball::MapGenerator::FactoryBotStrategy.new
        end
      CONFIG
    end

    it 'adds mapped examples to a prediction list for Model1 factory' do
      model1_factory_path = spec_path.join('factories/model1s.rb')
      change model1_factory_path

      expect(forecast).to include_rspec_examples(
                                        './spec/models/model1_spec.rb[1:3:1]',
                                        './spec/models/model1_spec.rb[1:4:1]'
                          )
    end

    it 'adds mapped examples to a prediction list for Model1 factory modification' do
      model1_factory_modification_path = spec_path.join('factories/model1s_modification.rb')
      change model1_factory_modification_path

      expect(forecast).to include_rspec_examples(
                                        './spec/models/model1_spec.rb[1:3:1]',
                                        './spec/models/model1_spec.rb[1:4:1]'
                                      )
    end
  end
end
