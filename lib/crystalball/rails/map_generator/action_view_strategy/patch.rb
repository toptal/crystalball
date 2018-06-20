# frozen_string_literal: true

require 'action_view'

module Crystalball
  module Rails
    class MapGenerator
      class ActionViewStrategy
        # Module to add new patched `compile!` method to ActionView::Template
        module Patch
          class << self
            # Patches `ActionView::Template#compile!`. Renames original `compile!` to `cb_original_compile!` and
            # replaces it with custom one
            def apply!
              ::ActionView::Template.class_eval do
                include Patch

                alias_method :cb_original_compile!, :compile!
                alias_method :compile!, :cb_patched_compile!
              end
            end

            # Reverts original behavior of `ActionView::Template#compile!`
            def revert!
              ::ActionView::Template.class_eval do
                alias_method :compile!, :cb_original_compile! # rubocop:disable Lint/DuplicateMethods
                undef_method :cb_patched_compile!
              end
            end
          end

          # Will replace original `ActionView::Template#compile!`. Pushes path of a view to
          # `ActionViewStrategy.views` and calls original `compile!`
          def cb_patched_compile!(*args)
            ActionViewStrategy.views.push identifier
            cb_original_compile!(*args)
          end
        end
      end
    end
  end
end
