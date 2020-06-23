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

      # Returns the affected examples for a given list of files
      #
      # @param [Array<String>] files - the list of files to check
      # @return [Array<String>] related examples
      def affected_examples_for(files)
        example_groups.map do |uid, example_group_map|
          uid if files.any? { |file| example_group_map.include?(file) }
        end.compact
      end

      def clear!
        self.example_groups = {}
      end

      def examples
        keys
      end

      private

      attr_writer :example_groups
    end
  end
end
