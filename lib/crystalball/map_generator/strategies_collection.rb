# frozen_string_literal: true

module Crystalball
  class MapGenerator
    # Map generator strategy based on harvesting Coverage information during example execution
    class StrategiesCollection
      include Enumerable

      def initialize(strategies = [])
        @strategies = strategies
      end

      def run(case_map, example, &block)
        run_for_strategies(case_map, example, *_strategies.reverse, &block)
        case_map
      end

      def method_missing(method_name, *args, &block)
        _strategies.public_send(method_name, *args, &block) || super
      end

      def respond_to_missing?(method_name, *_args)
        _strategies.respond_to?(method_name, false) || super
      end

      private

      def _strategies
        @strategies
      end

      def run_for_strategies(case_map, example, *strats, &block)
        return yield(case_map) if strats.empty?

        strat = strats.shift
        strat.call(case_map, example) { |c| run_for_strategies(c, example, *strats, &block) }
      end
    end
  end
end
