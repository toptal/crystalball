# frozen_string_literal: true

module Crystalball
  class MapGenerator
    # Map generator strategy interface
    module BaseStrategy
      def after_register; end

      def after_start; end

      def before_finalize; end

      # Each strategy must implement #call augmenting the affected_files list and
      # yielding back the CaseMap.
      # @param [Crystalball::CaseMap] _case_map - object holding example metadata and affected files
      def call(_case_map, _example)
        raise NotImplementedError
      end
    end
  end
end
