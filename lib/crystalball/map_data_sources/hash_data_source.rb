# frozen_string_literal: true

module Crystalball
  module MapDataSources
    # Simple data source wrapping around a hash
    class HashDataSource
      extend Forwardable

      delegate %i[size [] []= keys] => :example_groups

      attr_reader :example_groups

      def initialize(example_groups: {})
        @example_groups = example_groups
      end

      def clear!
        self.example_groups = {}
      end

      private

      attr_writer :example_groups
    end
  end
end
