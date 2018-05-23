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

      attr_reader :cases, :metadata

      delegate %i[commit version] => :metadata
      delegate %i[size [] []=] => :cases

      # @param [Hash] metadata - add or override metadata of execution map
      # @param [Hash] cases - initial list of tables
      def initialize(metadata: {}, cases: {})
        @metadata = Metadata.new(**metadata)
        @cases = cases
      end

      # Remove all cases
      def clear!
        self.cases = {}
      end

      def add(files:, for_table:)
        cases[for_table] ||= []
        cases[for_table] += files
        cases[for_table].uniq!
      end

      private

      attr_writer :cases, :metadata
    end
  end
end
