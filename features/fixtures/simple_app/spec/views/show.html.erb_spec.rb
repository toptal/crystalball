# frozen_string_literal: true

require 'spec_helper'

describe 'show.html.erb' do
  include_context 'action view'
  let(:assigns) { {model: Model1.new(field: 'foo')} }

  it { is_expected.to include 'foo' }
end
