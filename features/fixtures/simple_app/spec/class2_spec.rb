# frozen_string_literal: true

require 'spec_helper'

describe Class2 do
  subject { Class2.new }

  include_examples 'module1'

  describe '#bar' do
    subject { super().bar }

    it { is_expected.to eq 'bar of Class2' }
  end
end
