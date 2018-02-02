# frozen_string_literal: true

module Crystalball
  module Rails
    class MapGenerator
      class ActionViewStrategy
        # Module to add new patched `compile!` method to ActionView::Template
        module Patch
          class << self
            # Patches `ActionView::Template#compile!`. Renames original `compile!` to `old_compile!` and
            # replaces it with custom one
            def apply!
              ::ActionView::Template.class_eval do
                include Patch
                alias_method :old_compile!, :compile!
                alias_method :compile!, :new_compile!
              end
            end

            # Reverts original behavior of `ActionView::Template#compile!`
            def revert!
              ::ActionView::Template.class_eval do
                alias_method :compile!, :old_compile! # rubocop:disable Lint/DuplicateMethods
                undef_method :new_compile!
              end
            end
          end

          # Will replace original `ActionView::Template#compile!`. Pushes path of a vew to
          # `ActionViewStrategy.views` and calls original `compile!`
          def new_compile!(*args)
            ActionViewStrategy.views.push identifier
            old_compile!(*args)
          end
        end
      end
    end
  end
end
