# frozen_string_literal: true

require_relative '../feature_helper'

describe 'Changing source file in a branch' do
  include_context 'simple git repository'
  include_context 'class1 examples'
  include_context 'base forecast'

  map_generator_config do
    <<~CONFIG
      Crystalball::MapGenerator.start! do |c|
        c.register Crystalball::MapGenerator::DescribedClassStrategy.new
      end
    CONFIG
  end

  let(:strategies) do
    [Crystalball::Predictor::ModifiedExecutionPaths.new]
  end

  let(:model1_examples) do
    [
      './spec/models/model1_spec.rb[1:1:1]',
      './spec/models/model1_spec.rb[1:2:1]',
      './spec/models/model1_spec.rb[1:3:1]',
      './spec/models/model1_spec.rb[1:4:1]'
    ]
  end

  before do
    change(class1_path)
    git.add(class1_path.to_s)
    git.commit('Second commit')
    git.checkout('HEAD^')
    git.branch('test').checkout
    change(model1_path)
  end

  it 'adds mapped examples to a prediction list for model1 only' do
    expect(forecast).to match_array(model1_examples)
  end
end
