# frozen_string_literal: true

require_relative '../feature_helper'

describe 'Moving support spec file' do
  include_context 'simple git repository'
  include_context 'base forecast'

  map_generator_config do
    <<~CONFIG
      Crystalball::MapGenerator.start! do |c|
        c.register Crystalball::MapGenerator::CoverageStrategy.new
      end
    CONFIG
  end

  let(:strategies) { [Crystalball::Predictor::ModifiedSupportSpecs.new] }

  it 'adds full spec to a prediction list' do
    move action_view_shared_context

    expect(forecast).to include_rspec_examples('./spec/views/index.html.erb_spec.rb',
                                               './spec/views/show.html.erb_spec.rb')
  end
end
