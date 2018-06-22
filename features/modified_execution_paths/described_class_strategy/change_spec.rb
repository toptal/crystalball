# frozen_string_literal: true

require_relative '../../feature_helper'

describe 'Changing source file' do
  include_context 'simple git repository'
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

  let(:class1_examples) do
    [
      './spec/class1_spec.rb[1:1:1]',
      './spec/class1_spec.rb[1:1:2:1]',
      './spec/class1_spec.rb[1:1:3:1]',
      './spec/class1_spec.rb[1:1:4:1]',
      './spec/class1_spec.rb[1:2:1]',
      './spec/class1_spec.rb[1:3:1]',
      './spec/class1_spec.rb[1:4:1]'
    ]
  end

  it 'adds mapped examples to a prediction list for Class1 definition' do
    change class1_path

    expect(forecast).to include(*class1_examples)
  end

  it 'adds mapped examples to a prediction list for Class1 reopen' do
    class1_reopen_path = lib_path.join('class1_reopen.rb')
    change class1_reopen_path

    expect(forecast).to include(*class1_examples)
  end

  it 'adds mapped examples to a prediction list for Class2 definition' do
    change class2_path

    expect(forecast).to include(
      './spec/class2_spec.rb[1:1:1]',
      './spec/class2_spec.rb[1:1:2:1]',
      './spec/class2_spec.rb[1:1:3:1]',
      './spec/class2_spec.rb[1:1:4:1]',
      './spec/class2_spec.rb[1:2:1]',
      './spec/class2_spec.rb[1:3:1]',
      './spec/class2_spec.rb[1:4:1]',
      './spec/class2_spec.rb[1:5:1]',
      './spec/class2_spec.rb[1:6:1]'
    )
  end

  it 'adds mapped examples to a prediction list for Module1 definition' do
    module1_path = lib_path.join('module1.rb')
    change module1_path

    expect(forecast).to include(
      './spec/class1_spec.rb[1:1:1]',
      './spec/class1_spec.rb[1:1:2:1]',
      './spec/class1_spec.rb[1:1:3:1]',
      './spec/class1_spec.rb[1:1:4:1]',
      './spec/class1_spec.rb[1:2:1]',
      './spec/class2_spec.rb[1:1:1]',
      './spec/class2_spec.rb[1:1:2:1]',
      './spec/class2_spec.rb[1:1:3:1]',
      './spec/class2_spec.rb[1:1:4:1]',
      './spec/class2_spec.rb[1:2:1]',
      './spec/class2_spec.rb[1:4:1]',
      './spec/class2_spec.rb[1:5:1]'
    )
  end

  it 'adds mapped examples to a prediction list for Module2 definition' do
    module2_path = lib_path.join('module2.rb')
    change module2_path

    expect(forecast).to include(
      './spec/class2_spec.rb[1:1:1]',
      './spec/class2_spec.rb[1:1:2:1]',
      './spec/class2_spec.rb[1:1:3:1]',
      './spec/class2_spec.rb[1:1:4:1]',
      './spec/class2_spec.rb[1:2:1]',
      './spec/class2_spec.rb[1:3:1]',
      './spec/class2_spec.rb[1:4:1]',
      './spec/class2_spec.rb[1:5:1]'
    )
  end

  it 'adds mapped examples to a prediction list for Model1 definition' do
    change model1_path

    expect(forecast).to include(
      './spec/models/model1_spec.rb[1:2:1]',
      './spec/models/model1_spec.rb[1:3:1]',
      './spec/models/model1_spec.rb[1:4:1]'
    )
  end
end
