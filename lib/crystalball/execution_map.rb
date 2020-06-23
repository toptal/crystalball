# frozen_string_literal: true

module Crystalball
  # Storage for execution map
  class ExecutionMap
    extend Forwardable

    # Simple data object for map metadata information
    class Metadata
      attr_reader :commit, :type, :version, :timestamp

      # @param [String] commit - SHA of commit
      # @param [String] type - type of execution map
      # @param [Numeric] version - map generator version number
      def initialize(commit: nil, type: nil, version: nil, timestamp: nil)
        @commit = commit
        @type = type
        @timestamp = timestamp
        @version = version
      end

      def to_h
        {type: type, commit: commit, timestamp: timestamp, version: version}
      end
    end

    attr_reader :map_data_source, :metadata

    delegate %i[commit version timestamp] => :metadata
    delegate %i[clear! size example_groups] => :map_data_source

    # @param [Hash] metadata - add or override metadata of execution map
    # @param [#[]] map_data_source - initial list of example groups data
    def initialize(metadata: {}, map_data_source: Crystalball::MapDataSources::HashDataSource.new)
      @map_data_source = map_data_source

      @metadata = Metadata.new(type: self.class.name, **metadata)
    end

    # Adds example group map to the list
    #
    # @param [Crystalball::ExampleGroupMap] example_group_map
    def <<(example_group_map)
      map_data_source[example_group_map.uid] = example_group_map.used_files.uniq
    end

    # Returns the affected examples for a given list of files
    #
    # @param [Array<String>] files - the list of files to check
    # @return [Array<String>] related examples
    def affected_examples(files:)
      map_data_source.affected_examples_for(files)
    end

    private

    attr_writer :metadata
  end
end
