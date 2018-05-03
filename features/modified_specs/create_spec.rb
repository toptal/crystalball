# frozen_string_literal: true

require_relative '../feature_helper'

describe 'Creating spec file' do
  include_context 'simple git repository'
  include_context 'base forecast'

  let(:strategies) { [Crystalball::Predictor::ModifiedSpecs.new] }

  it 'adds it to a prediction list' do
    new_spec_path = spec_path.join('new_spec.rb')
    new_spec_path.open('w') { |f| f.write(<<~RUBY) }
      require 'spec_helper'

      describe 'new spec' do
        specify { expect(Class1.new).not_to be_nil }
      end
    RUBY
    git.add(new_spec_path.to_s)

    expect(forecast).to match_array(%w[./spec/new_spec.rb])
  end
end
