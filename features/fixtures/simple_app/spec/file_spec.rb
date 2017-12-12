# frozen_string_literal: true

require 'spec_helper'

describe 'my specs' do
  it { expect(Class1.new).to be_a(Class1) }

  it { expect(Class2.new).to be_a(Class2) }
end
