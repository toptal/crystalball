# frozen_string_literal: true

module Crystalball
  module RSpec
    module PredictionPruning
      # A class to prune given world example groups to fit the limit.
      class ExamplesPruner
        # Simple data object for holding context ids array with total examples size
        class ContextIdsSet
          attr_reader :ids, :size
          alias to_a ids

          def initialize
            @size = 0
            @ids = []
          end

          def add(id, size = 1)
            @size += size
            @ids << id
          end
        end

        attr_reader :world, :limit

        # @param [RSpec::Core::World] rspec_world RSpec world instance
        # @param [Integer] to upper bound limit for prediction.
        def initialize(rspec_world, to:)
          @world = rspec_world
          @limit = to
        end

        # @return [Array<String>] set of example and context ids to run
        def pruned_set
          resulting_set = ContextIdsSet.new
          world.ordered_example_groups.each { |g| prune_to_limit(g, resulting_set) }
          resulting_set.to_a
        end

        private

        def prune_to_limit(group, resulting_set)
          return if resulting_set.size >= limit

          group_size = world.example_count([group])

          if resulting_set.size + group_size > limit
            (group.descendants - [group]).each do |g|
              prune_to_limit(g, resulting_set)
            end

            add_examples(group, resulting_set)
          else
            resulting_set.add(group.id, group_size)
          end
        end

        def add_examples(group, resulting_set)
          limit_diff = limit - resulting_set.size

          return unless limit_diff.positive?

          group.filtered_examples.first(limit_diff).each do |example|
            resulting_set.add(example.id)
          end
        end
      end
    end
  end
end
