# frozen_string_literal: true

module Crystalball
  module RSpec
    # A class to prune prediction size to specified limit.
    class ExamplesPruner
      attr_reader :world, :to

      # @param [RSpec::Core::World] rspec_world RSpec world instance
      # @param [Integer] to upper bound limit for prediction.
      def initialize(rspec_world, to:)
        @world = rspec_world
        @to = to
      end

      def world_groups
        @world_groups ||= world.ordered_example_groups
      end

      def pruned_groups
        self.resulting_groups = []
        self.resulting_size = 0

        world_groups.each { |g| prune_to_limit(g) }

        resulting_groups
      end

      private

      attr_accessor :resulting_groups, :resulting_size

      def add_group(group, group_size)
        resulting_groups << group
        self.resulting_size = resulting_size + group_size
      end

      def prune_to_limit(group)
        return if resulting_size >= to

        group_size = world.example_count([group])

        if resulting_size + group_size > to
          (group.descendants - [group]).each do |g|
            prune_to_limit(g)
          end
        else
          add_group(group, group_size)
        end
      end
    end
  end
end
