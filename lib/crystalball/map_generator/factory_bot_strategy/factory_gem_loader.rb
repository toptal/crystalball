# frozen_string_literal: true

module Crystalball
  class MapGenerator
    class FactoryBotStrategy
      # A helper module to load `factory_bot` or `factory_girl`
      module FactoryGemLoader
        class << self
          NAMES = %w[factory_bot factory_girl].freeze

          # Tries to require `factory_bot` first. Requires `factory_girl` if `factory_bot` is not available
          # Raises `LoadError` if both of them are not available.
          def require!
            NAMES.any? do |factory_gem_name|
              begin
                require factory_gem_name
                true
              rescue LoadError
                false
              end
            end || (raise LoadError, "Can't load `factory_bot` or `factory_girl`")
          end
        end
      end
    end
  end
end
