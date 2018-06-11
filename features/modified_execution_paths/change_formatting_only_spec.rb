# frozen_string_literal: true

require_relative '../feature_helper'

describe 'Changing formatting in a source file' do
  include_context 'simple git repository'
  include_context 'class1 examples'
  include_context 'base forecast'

  let(:strategies) do
    [Crystalball::Predictor::ModifiedExecutionPaths.new]
  end

  it 'does not add any examples to a prediction list' do
    change class1_path, File.read(fixtures_path.join('class1_formatting_changed.rb'))

    expect(forecast).to be_empty
  end
end
