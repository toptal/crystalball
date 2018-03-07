# frozen_string_literal: true

module Crystalball
  class MapGenerator
    # Manages map generation strategies
    class StrategiesCollection
      include Enumerable

      def initialize(strategies = [])
        @strategies = strategies
      end

      # Calls every strategy on the given case map and returns the modified case map
      # @param [Crystalball::CaseMap] initial case map
      # @return [Crystalball::CaseMap] case map augmented by each strategy
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
