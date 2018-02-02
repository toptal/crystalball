# frozen_string_literal: true

require 'crystalball/map_generator/base_strategy'
require 'crystalball/rails/map_generator/action_view_strategy/execution_detector'
require 'crystalball/rails/map_generator/action_view_strategy/patch'

module Crystalball
  module Rails
    class MapGenerator
      # Map generator strategy to build map of views affected by an example.
      # It patches `ActionView::Template#compile!` to get original name of compiled views.
      class ActionViewStrategy
        include Crystalball::MapGenerator::BaseStrategy

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

        attr_reader :execution_detector

        def initialize(execution_detector = ExecutionDetector.new(Dir.pwd))
          @execution_detector = execution_detector
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
          case_map.push(*execution_detector.detect(self.class.views))
        end
      end
    end
  end
end
