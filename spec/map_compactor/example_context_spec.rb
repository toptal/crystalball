# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapCompactor::ExampleContext do
  subject(:example_context) { described_class.new(address) }

  describe '#include?' do
    let(:address) { '1:2' }
    specify do
      expect(subject).to include 'file_spec.rb[1:2]'
      expect(subject).to include 'file_spec.rb[1:2:3]'
      expect(subject).to include 'file_spec.rb[1:2:3:4]'
      expect(subject).not_to include 'file_spec.rb[1:1]'
      expect(subject).not_to include 'file_spec.rb[2:2]'
      expect(subject).not_to include 'file_spec.rb[1:21]'
      expect(subject).not_to include 'file_spec.rb[1]'
      expect(subject).not_to include 'file_spec.rb'
    end
  end

  describe '#depth' do
    subject { example_context.depth }

    let(:address) { '1:2:3:1:2' }

    it { is_expected.to eq 5 }
  end

  describe '#parent' do
    subject { example_context.parent }

    let(:address) { '1:2:3' }

    specify do
      expect(subject).to be_a described_class
      expect(subject.address).to eq '1:2'
    end
  end
end
