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

    attr_reader :example_groups, :metadata

    delegate %i[commit version timestamp] => :metadata
    delegate %i[size] => :example_groups

    # @param [Hash] metadata - add or override metadata of execution map
    # @param [Hash] example_groups - initial list of example groups data
    def initialize(metadata: {}, example_groups: {})
      @example_groups = example_groups

      @metadata = Metadata.new(type: self.class.name, **metadata)
    end

    # Adds example group map to the list
    #
    # @param [Crystalball::ExampleGroupMap] example_group_map
    def <<(example_group_map)
      example_groups[example_group_map.uid] = example_group_map.used_files.uniq
    end

    # Remove all example_groups
    def clear!
      self.example_groups = {}
    end

    private

    attr_writer :example_groups, :metadata
  end
end
