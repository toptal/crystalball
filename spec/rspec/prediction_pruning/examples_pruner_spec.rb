# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::RSpec::PredictionPruning::ExamplesPruner do
  subject(:pruner) { described_class.new(world, to: limit) }
  let(:world) { instance_double('RSpec::Core::World') }

  describe '#pruned_set' do
    subject { pruner.pruned_set }

    def self.rspec_group(name, size: 0, descendants: [], examples: [])
      let(name) do
        subgroups = descendants.map { |d| send(d) }
        stub_const("RSpecTestGroup::#{name.to_s.upcase}", Class.new(RSpec::Core::ExampleGroup)).tap do |klass|
          allow(klass).to receive(:descendants).and_return([klass] + subgroups)
          allow(klass).to receive(:id).and_return(name)
          allow(klass).to receive(:filtered_examples).and_return(examples.map { |e| send(e) })
          allow(world).to receive(:example_count).with([klass]).and_return(size)
        end
      end
    end
    rspec_group(:subgroup1, size: 2)
    rspec_group(:subgroup2, size: 3)
    rspec_group(:subgroup3, size: 4)
    rspec_group(:subgroup4, size: 5)
    rspec_group(:subgroup5, size: 6)
    rspec_group(:subgroup6, size: 7)

    rspec_group(:group1, size: 10, descendants: %i[subgroup1 subgroup2 subgroup3], examples: [:example1])
    rspec_group(:group2, size: 18, descendants: %i[subgroup4 subgroup5 subgroup6])

    let(:example1) do
      instance_double('RSpec::Core::Example', id: :example1)
    end

    before do
      allow(world).to receive(:ordered_example_groups).and_return [group1, group2]
    end

    context 'when limit is more than total suite size' do
      let(:limit) { 10 + 18 + 1 }

      it { is_expected.to eq %i[group1 group2] }
    end

    context 'when limit is less than first group size' do
      let(:limit) { 5 }

      it { is_expected.to eq %i[subgroup1 subgroup2] }
    end

    context 'when limit cant be matched exactly by groups' do
      let(:limit) { 6 }

      it 'adds single examples' do
        is_expected.to eq %i[subgroup1 subgroup2 example1]
      end
    end

    context 'when limit is less than smallest group' do
      let(:limit) { 1 }

      it 'adds single examples up to the limit' do
        is_expected.to eq [:example1]
      end
    end
  end
end
