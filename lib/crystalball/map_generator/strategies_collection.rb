# frozen_string_literal: true

module Crystalball
  # Class for generating execution map during RSpec build execution
  class MapGenerator
    # Map generator strategy based on harvesting Coverage information during example execution
    class StrategiesCollection
      include Enumerable
      extend Forwardable

      delegate %i[each empty? push] => :_strategies

      def initialize(strategies = [])
        @strategies = strategies
      end

      def run(case_map, &block)
        run_for_strategies(case_map, *_strategies, &block)
        case_map
      end

      private

      def _strategies
        @strategies
      end

      def run_for_strategies(case_map, *strats, &block)
        return yield(case_map) if strats.empty?

        strat = strats.shift
        strat.call(case_map) { |c| run_for_strategies(c, *strats, &block) }
      end
    end
  end
end
