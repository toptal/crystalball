# frozen_string_literal: true

require_relative '../feature_helper'

describe 'Moving source file' do
  include_context 'simple git repository'
  include_context 'class1 examples'
  include_context 'base forecast'

  map_generator_config do
    <<~CONFIG
      Crystalball::MapGenerator.start! do |c|
        c.register Crystalball::MapGenerator::CoverageStrategy.new
      end
    CONFIG
  end

  let(:strategies) do
    [Crystalball::Predictor::ModifiedExecutionPaths.new]
  end

  it 'adds mapped examples to a prediction list' do
    move class1_path

    expect(forecast).to include(*class1_examples)
  end
end
