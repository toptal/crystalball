# frozen_string_literal: true

require_relative '../feature_helper'

describe 'Changing source file' do
  include_context 'simple git repository'
  include_context 'class1 examples'
  include_context 'model1 examples'
  include_context 'base forecast'

  let(:strategies) do
    [Crystalball::Predictor::ModifiedExecutionPaths.new]
  end

  it 'adds mapped examples to a prediction list for Class1 definition' do
    change class1_path

    expect(forecast).to include(*class1_examples)
  end

  it 'adds mapped examples to a prediction list for Class1 reopen' do
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
      './spec/class2_spec.rb[1:4:1]',
      './spec/class2_spec.rb[1:5:1]',
      './spec/class2_spec.rb[1:6:1]',
      './spec/file_spec.rb[1:2]'
    )
  end

  it 'adds mapped examples to a prediction list for Module1 definition' do
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
      './spec/class2_spec.rb[1:5:1]',
      './spec/file_spec.rb[1:2]'
    )
  end

  it 'adds mapped examples to a prediction list for Module2 definition' do
    change module2_path

    expect(forecast).to include(
      './spec/class2_spec.rb[1:1:1]',
      './spec/class2_spec.rb[1:1:2:1]',
      './spec/class2_spec.rb[1:1:3:1]',
      './spec/class2_spec.rb[1:1:4:1]',
      './spec/class2_spec.rb[1:2:1]',
      './spec/class2_spec.rb[1:3:1]',
      './spec/class2_spec.rb[1:4:1]',
      './spec/class2_spec.rb[1:5:1]',
      './spec/file_spec.rb[1:2]'
    )
  end

  it 'adds mapped examples to a prediction list for Model1 definition' do
    change model1_path

    expect(forecast).to include(*model1_examples)
  end

  it 'adds mapped examples to a prediction list for Model1 factory' do
    change model1_factory_path

    expect(forecast).to match_array([
                                      './spec/models/model1_spec.rb[1:3:1]',
                                      './spec/models/model1_spec.rb[1:4:1]'
                                    ])
  end

  it 'adds mapped examples to a prediction list for Model1 factory modification' do
    change model1_factory_modification_path

    expect(forecast).to match_array([
                                      './spec/models/model1_spec.rb[1:3:1]',
                                      './spec/models/model1_spec.rb[1:4:1]'
                                    ])
  end

  it 'adds mapped examples to a prediction list for _item view' do
    change item_view_path

    expect(forecast).to include(
      './spec/views/index.html.erb_spec.rb[1:1]',
      './spec/views/index.html.erb_spec.rb[1:2]',
      './spec/views/index.html.erb_spec.rb[1:3]',
      './spec/views/show.html.erb_spec.rb[1:1]'
    )
  end

  it 'adds mapped examples to a prediction list for name locale' do
    change name_locale_path

    expect(forecast).to include(
      './spec/class1_spec.rb[1:3:1]',
      './spec/class2_spec.rb[1:3:1]'
    )
  end

  it 'adds mapped examples to a prediction list for value locale' do
    change value_locale_path

    expect(forecast).to include(
      './spec/class2_spec.rb[1:6:1]'
    )
  end
end
