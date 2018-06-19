# frozen_string_literal: true

module Crystalball
  module Rails
    # Storage for tables map
    class TablesMap
      extend Forwardable

      # Simple data object for map metadata information
      class Metadata
        attr_reader :commit, :version

        # @param [String] commit - SHA of commit
        # @param [Numeric] version - map generator version number
        def initialize(commit: nil, version: nil, **_)
          @commit = commit
          @version = version
        end

        def to_h
          {type: TablesMap.name, commit: commit, version: version}
        end
      end

      attr_reader :example_groups, :metadata

      delegate %i[commit version] => :metadata
      delegate %i[size [] []=] => :example_groups

      # @param [Hash] metadata - add or override metadata of execution map
      # @param [Hash] example_groups - initial list of tables
      def initialize(metadata: {}, example_groups: {})
        @metadata = Metadata.new(**metadata)
        @example_groups = example_groups
      end

      # Remove all example_groups
      def clear!
        self.example_groups = {}
      end

      def add(files:, for_table:)
        example_groups[for_table] ||= []
        example_groups[for_table] += files
        example_groups[for_table].uniq!
      end

      private

      attr_writer :example_groups, :metadata
    end
  end
end
