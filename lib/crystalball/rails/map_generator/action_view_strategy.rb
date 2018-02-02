# frozen_string_literal: true

require 'crystalball/map_generator/base_strategy'
require 'crystalball/rails/map_generator/action_view_strategy/execution_detector'
require 'crystalball/rails/map_generator/action_view_strategy/patch'

module Crystalball
  module Rails
    # Class for generating execution map during RSpec build execution
    class MapGenerator
      # Map generator strategy to build map of views affected by an example.
      # It patches ActionView::Renderer.render to get original name of compiled views.
      class ActionViewStrategy
        include Crystalball::MapGenerator::BaseStrategy

        class << self
          attr_reader :views

          def reset_views
            @views = []
          end
        end

        attr_reader :execution_detector

        def initialize(execution_detector = ExecutionDetector.new(Dir.pwd))
          @execution_detector = execution_detector
        end

        def after_start
          ::ActionView::Template.class_eval do
            include Crystalball::Rails::MapGenerator::ActionViewStrategy::Patch
            alias_method :old_compile!, :compile!
            alias_method :compile!, :new_compile!
          end
        end

        def before_finalize
          ::ActionView::Template.class_eval do
            alias_method :compile!, :old_compile! # rubocop:disable Lint/DuplicateMethods
          end
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
