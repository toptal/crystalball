# frozen_string_literal: true

module Crystalball
  module Rails
    class MapGenerator
      class ActionViewStrategy
        # Module to add new patched `compile!` method to ActionView::Template
        module Patch
          def new_compile!(mod)
            Crystalball::Rails::MapGenerator::ActionViewStrategy.views.push identifier
            old_compile!(mod)
          end
        end
      end
    end
  end
end
