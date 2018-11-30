# frozen_string_literal: true

require_relative '../feature_helper'

RSpec.describe 'Changing schema file' do
  include_context 'simple git repository'
  include_context 'base forecast'
  let(:schema_path) { root.join('db', 'schema.rb') }

  map_generator_config do
    <<~CONFIG
      Crystalball::MapGenerator.start! do |c|
        c.register Crystalball::MapGenerator::DescribedClassStrategy.new
      end

      Crystalball::Rails::TablesMapGenerator.start!
    CONFIG
  end

  let(:model1_examples) do
    [
      './spec/models/model1_spec.rb[1:1:1]',
      './spec/models/model1_spec.rb[1:2:1]',
      './spec/models/model1_spec.rb[1:3:1]',
      './spec/models/model1_spec.rb[1:4:1]'
    ]
  end

  let(:strategies) do
    [Crystalball::Rails::Predictor::ModifiedSchema.new(tables_map_path: root.join('tables_map.yml'))]
  end

  it 'adds mapped examples to a prediction list' do
    change schema_path, File.read(fixtures_path.join('schema', 'model_table_changed.rb'))

    expect(forecast).to include_rspec_examples(*model1_examples)
    expect(forecast).not_to include_rspec_examples('./spec/models/model2_spec.rb[1:1:1]')
  end

  it 'writes a warning for a table with no model files' do
    change schema_path, File.read(fixtures_path.join('schema', 'relation_table_changed.rb'))

    expect(Crystalball).to receive(:log).with(:warn, /There are no model files for changed table `model1s_model2s`/)
    expect(forecast).to be_empty
  end
end
