# frozen_string_literal: true

require_relative '../../feature_helper'

describe 'Changing source file' do
  include_context 'simple git repository'
  include_context 'base forecast'

  let(:strategies) do
    [Crystalball::Predictor::ModifiedExecutionPaths.new]
  end

  context 'when dealing with views' do
    let(:item_view_path) { root.join('views', '_item.html.erb') }

    map_generator_config do
      <<~CONFIG
        Crystalball::MapGenerator.start! do |c|
          c.register Crystalball::Rails::MapGenerator::ActionViewStrategy.new
        end
      CONFIG
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
  end
end
