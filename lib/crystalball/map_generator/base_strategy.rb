# frozen_string_literal: true

module Crystalball
  # Class for generating execution map during RSpec build execution
  class MapGenerator
    # Map generator strategy interface
    module BaseStrategy
      def after_register; end

      def after_start; end

      def before_finalize; end

      def call(_case_map)
        raise NotImplementedError
      end
    end
  end
end
