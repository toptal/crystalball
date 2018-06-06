# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'ImportantClass and stuff' do
  it 'does very specific stuff' do
    expect(1).to eq(1)
  end

  it 'does stuff with Class2' do
    expect(Object.const_get('ImportantClass').foo).not_to be_nil
  end

  it 'does stuff with Class1' do
    expect(Object.const_get('ImportantClass').bar).not_to be_nil
  end
end
