# frozen_string_literal: true

require 'crystalball/map_generator/base_strategy'
require 'crystalball/map_generator/helpers/path_filter'
require 'crystalball/rails/map_generator/i18n_strategy/simple_patch'

module Crystalball
  module Rails
    class MapGenerator
      # Map generator strategy to build map of locale files used by an example.
      class I18nStrategy
        include ::Crystalball::MapGenerator::BaseStrategy
        include ::Crystalball::MapGenerator::Helpers::PathFilter

        class << self
          # List of locale files affected by current example
          #
          # @return [Array<String>]
          def locale_files
            @locale_files ||= []
          end

          # Reset cached list of locale files
          def reset_locale_files
            @locale_files = []
          end
        end

        def after_register
          SimplePatch.apply!
        end

        def before_finalize
          SimplePatch.revert!
        end

        # Adds to the case map the locale files used by the example
        # @param [Crystalball::CaseMap] case_map - object holding example metadata and affected files
        def call(case_map, _)
          self.class.reset_locale_files
          yield case_map
          case_map.push(*filter(self.class.locale_files.compact), strategy: name)
        end
      end
    end
  end
end
