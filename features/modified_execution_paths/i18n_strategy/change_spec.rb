# frozen_string_literal: true

require_relative '../../feature_helper'

describe 'Changing source file' do
  include_context 'simple git repository'
  include_context 'base forecast'

  let(:strategies) do
    [Crystalball::Predictor::ModifiedExecutionPaths.new]
  end

  context 'when dealing with locales' do
    let(:locales_path) { root.join('locales') }
    let(:name_locale_path) { locales_path.join('name.yml') }
    let(:value_locale_path) { locales_path.join('value.yml') }

    map_generator_config do
      <<~CONFIG
        Crystalball::MapGenerator.start! do |c|
          c.register Crystalball::Rails::MapGenerator::I18nStrategy.new
        end
      CONFIG
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
end
