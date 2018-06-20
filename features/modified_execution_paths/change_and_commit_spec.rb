# frozen_string_literal: true

require_relative '../feature_helper'

describe 'Changing and commiting a source file' do
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
    change class1_path
    git.add class1_path.to_s
    git.commit 'Second commit'

    expect(forecast).to include(*class1_examples)
  end
end
