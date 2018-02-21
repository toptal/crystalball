# frozen_string_literal: true

require 'crystalball/map_generator/base_strategy'
require 'crystalball/map_generator/helpers/path_filter'
require 'crystalball/rails/map_generator/action_view_strategy/patch'

module Crystalball
  module Rails
    class MapGenerator
      # Map generator strategy to build map of views affected by an example.
      # It patches `ActionView::Template#compile!` to get original name of compiled views.
      class ActionViewStrategy
        include ::Crystalball::MapGenerator::BaseStrategy
        include ::Crystalball::MapGenerator::Helpers::PathFilter

        class << self
          # List of views affected by current example
          #
          # @return [Array<String>]
          attr_reader :views

          # Reset cached list of views
          def reset_views
            @views = []
          end
        end

        def after_start
          Patch.apply!
        end

        def before_finalize
          Patch.revert!
        end

        def call(case_map)
          self.class.reset_views
          yield case_map
          case_map.push(*filter(self.class.views))
        end
      end
    end
  end
end
