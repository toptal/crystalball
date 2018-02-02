# frozen_string_literal: true

require 'spec_helper'

describe 'index.html.erb' do
  include_context 'action view'
  let(:assigns) { {models: [Model1.new('foo'), Model1.new('bar')]} }

  it { is_expected.to include('List of 2') }
  it { is_expected.to include('foo') }
  it { is_expected.to include('bar') }
end
