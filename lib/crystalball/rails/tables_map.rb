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

      attr_reader :map_data_source, :metadata

      delegate %i[commit version] => :metadata
      delegate %i[clear! size [] []= example_groups] => :map_data_source

      # @param [Hash] metadata - add or override metadata of execution map
      # @param [#[]] map_data_source - initial list of tables
      def initialize(metadata: {}, map_data_source: Crystalball::MapDataSources::HashDataSource.new)
        @metadata = Metadata.new(**metadata)
        @map_data_source = map_data_source
      end

      def add(files:, for_table:)
        map_data_source[for_table] ||= []
        map_data_source[for_table] += files
        map_data_source[for_table].uniq!
      end

      private

      attr_writer :metadata
    end
  end
end
