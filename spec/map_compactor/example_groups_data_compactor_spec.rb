# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapCompactor::ExampleGroupsDataCompactor do
  describe '.compact!' do
    subject { described_class.compact!(plain_data) }

    context 'with two independent contexts' do
      let(:plain_data) do
        {
          'file_spec.rb[1]' => 'one',
          'file_spec.rb[2]' => 'two'
        }
      end

      it 'returns the same data' do
        expect(subject).to eq('1' => 'one', '2' => 'two')
      end
    end

    context 'with some shared data' do
      let(:plain_data) do
        {
          'file_spec.rb[1:1]' => [1, 2, 3],
          'file_spec.rb[1:2]' => [1, 2, 4]
        }
      end

      it 'returns grouped data' do
        expect(subject).to eq('1' => [1, 2], '1:1' => [3], '1:2' => [4])
      end
    end

    context 'for deep nesting' do
      let(:plain_data) do
        {
          'file_spec.rb[1:1]' => [1, 2],
          'file_spec.rb[1:2]' => [1, 2, 3],
          'file_spec.rb[1:3]' => [1, 2, 3, 4],
          'file_spec.rb[1:4:1]' => [1, 2, 5],
          'file_spec.rb[1:4:2]' => [1, 2, 5, 6]
        }
      end

      it 'returns grouped data' do
        expect(subject).to eq(
          '1' => [1, 2],
          '1:1' => [],
          '1:2' => [3],
          '1:3' => [3, 4],
          '1:4' => [5],
          '1:4:1' => [],
          '1:4:2' => [6]
        )
      end
    end
  end
end
