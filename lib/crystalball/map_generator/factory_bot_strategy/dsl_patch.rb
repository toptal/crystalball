# frozen_string_literal: true

require 'crystalball/map_generator/factory_bot_strategy/dsl_patch/factory_path_fetcher'

module Crystalball
  class MapGenerator
    class FactoryBotStrategy
      # Module to add new `factory` method to FactoryBot::Syntax::Default::DSL and FactoryBot::Syntax::Default::ModifyDSL
      module DSLPatch
        class << self
          # Patches `FactoryBot::Syntax::Default::DSL#factory` and `FactoryBot::Syntax::Default::ModifyDSL#factory`.
          def apply!
            classes_to_patch.each { |klass| klass.prepend DSLPatch }
          end

          private

          def classes_to_patch
            [
              FactoryBotStrategy.factory_bot_constant::Syntax::Default::DSL,
              FactoryBotStrategy.factory_bot_constant::Syntax::Default::ModifyDSL
            ]
          end
        end

        # Overrides `FactoryBot::Syntax::Default::DSL#factory` and `FactoryBot::Syntax::Default::ModifyDSL#factory`.
        # Pushes path of a factory to `FactoryBotStrategy.factory_definitions` and calls original `factory`
        def factory(*args, &block)
          factory_path = FactoryPathFetcher.fetch
          name = args.first.to_s

          FactoryBotStrategy.factory_definitions[name] ||= []
          FactoryBotStrategy.factory_definitions[name] << factory_path

          super
        end
      end
    end
  end
end
