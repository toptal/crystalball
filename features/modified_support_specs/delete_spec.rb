# frozen_string_literal: true

require_relative '../feature_helper'

describe 'Deleting support spec file' do
  include_context 'simple git repository'
  include_context 'base forecast'

  let(:strategies) { [Crystalball::Predictor::ModifiedSupportSpecs.new] }

  it 'adds full spec to a prediction list' do
    delete action_view_shared_context

    expect(forecast).to match_array([
                                      './spec/views/index.html.erb_spec.rb',
                                      './spec/views/show.html.erb_spec.rb'
                                    ])
  end
end
