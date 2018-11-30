# frozen_string_literal: true

require_relative '../../feature_helper'

describe 'Changing source file with a class method call' do
  include_context 'base forecast'
  include_context 'simple git repository'

  map_generator_config do
    <<~CONFIG
      Crystalball::MapGenerator.start! do |c|
        c.register Crystalball::MapGenerator::CoverageStrategy.new
        c.register Crystalball::MapGenerator::ParserStrategy.new(pattern: %r{(lib/)})
      end
    CONFIG
  end

  let(:strategies) { [Crystalball::Predictor::ModifiedExecutionPaths.new] }

  it 'adds class2 example when class1 changes' do
    change class1_path

    expect(forecast).to include_rspec_examples(
      './spec/class2_spec.rb[1:4:1]'
    )
  end
end
