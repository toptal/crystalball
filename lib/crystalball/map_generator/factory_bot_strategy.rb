# frozen_string_literal: true

require 'crystalball/map_generator/factory_bot_strategy/factory_gem_loader'

Crystalball::MapGenerator::FactoryBotStrategy::FactoryGemLoader.require!

require 'crystalball/map_generator/base_strategy'
require 'crystalball/map_generator/helpers/path_filter'
require 'crystalball/map_generator/factory_bot_strategy/dsl_patch'
require 'crystalball/map_generator/factory_bot_strategy/factory_runner_patch'

module Crystalball
  class MapGenerator
    # Map generator strategy to include list of strategies which was used in an example.
    class FactoryBotStrategy
      include ::Crystalball::MapGenerator::BaseStrategy
      include ::Crystalball::MapGenerator::Helpers::PathFilter

      class << self
        def factory_bot_constant
          defined?(::FactoryBot) ? ::FactoryBot : ::FactoryGirl
        end

        # List of factories used by current example
        #
        # @return [Array<String>]
        def used_factories
          @used_factories ||= []
        end

        # Map of factories to files
        #
        # @return [Hash<String, String>]
        def factory_definitions
          @factory_definitions ||= {}
        end

        # Reset cached list of factories
        def reset_used_factories
          @used_factories = []
        end
      end

      def after_register
        DSLPatch.apply!
        FactoryRunnerPatch.apply!
      end

      # Adds factories related to the spec to the map
      # @param [Crystalball::ExampleGroupMap] example_map - object holding example metadata and used files
      # @param [RSpec::Core::Example] example - a RSpec example
      def call(example_map, example)
        self.class.reset_used_factories
        yield example_map, example
        example_map.push(*filter(self.class.used_factories.flat_map { |f| self.class.factory_definitions[f] }))
      end
    end
  end
end
