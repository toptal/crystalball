# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::Prediction do
  subject(:prediction) { described_class.new(raw_example_groups) }
  let(:raw_example_groups) { [] }

  describe '#to_a' do
    subject { prediction.to_a }
    it { is_expected.to eq raw_example_groups }
  end

  describe '#compact' do
    subject { prediction.compact }
    context 'when one part is included into other part' do
      let(:raw_example_groups) do
        %w[
          ./dir/file1_spec.rb
          ./dir/
          ./file2_spec.rb
          ./file2_spec.rb[1:1]
        ]
      end

      it { is_expected.to match_array(%w[./dir/ ./file2_spec.rb]) }
    end

    context 'when prediction includes root' do
      let(:raw_example_groups) do
        %w[
          ./
          ./dir/file1_spec.rb
          ./dir/
          ./file2_spec.rb
          ./file2_spec.rb[1:1]
        ]
      end

      it { is_expected.to match_array(%w[./]) }
    end
  end

  describe '#method_missing' do
    it 'is delegated to raw_example_groups' do
      expect(raw_example_groups).to receive(:size).once
      subject.size
    end
  end

  describe '#respond_to_missing?' do
    it 'is delegated to raw_example_groups' do
      expect(subject).to respond_to(:size)
    end
  end
end
