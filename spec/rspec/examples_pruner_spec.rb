# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::RSpec::ExamplesPruner  do
  subject(:pruner) { described_class.new(world, to: limit) }

  let(:world) { instance_double('RSpec::Core::World') }
  let(:limit) { 100 }

  describe '#world_groups' do
    it 'returns example groups from RSpec world' do
      groups = double
      allow(world).to receive(:ordered_example_groups).and_return(groups)
      expect(subject.world_groups).to eq groups
    end
  end

  describe '#pruned_groups' do
    subject { pruner.pruned_groups }

    def self.rspec_group(name, size: 0, descendants: [])
      let(name) do
        subgroups = descendants.map { |d| send(d) }
        stub_const("RSpecTestGroup::#{name.to_s.upcase}", Class.new(RSpec::Core::ExampleGroup)).tap do |klass|
          allow(klass).to receive(:descendants).and_return([klass] + subgroups)
          allow(world).to receive(:example_count).with([klass]).and_return(size)
        end
      end
    end
    rspec_group(:subgroup1, size: 1)
    rspec_group(:subgroup2, size: 2)
    rspec_group(:subgroup3, size: 3)
    rspec_group(:subgroup4, size: 4)
    rspec_group(:subgroup5, size: 5)
    rspec_group(:subgroup6, size: 6)

    rspec_group(:group1, size: 6, descendants: %i[subgroup1 subgroup2 subgroup3])
    rspec_group(:group2, size: 15, descendants: %i[subgroup4 subgroup5 subgroup6])

    before do
      allow(world).to receive(:ordered_example_groups).and_return [group1, group2]
    end

    context 'when limit is more than total suite size' do
      let(:limit) { 6 + 15 + 1 }

      it { is_expected.to eq [group1, group2] }
    end

    context 'when limit is less than first group size' do
      let(:limit) { 3 }

      it { is_expected.to eq [subgroup1, subgroup2] }
    end

    context 'when limit cant be matched exactly' do
      let(:limit) { 14 }

      it 'does not go over the limit' do
        is_expected.to eq [group1, subgroup4]
      end
    end
  end
end
