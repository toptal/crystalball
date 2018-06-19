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

    attr_reader :cases, :metadata

    delegate %i[commit version timestamp] => :metadata
    delegate %i[size] => :cases

    # @param [Hash] metadata - add or override metadata of execution map
    # @param [Hash] cases - initial list of cases
    def initialize(metadata: {}, cases: {})
      @cases = cases

      @metadata = Metadata.new(type: self.class.name, **metadata)
    end

    # Adds example group map to the list
    #
    # @param [Crystalball::ExampleGroupMap] example_group_map
    def <<(example_group_map)
      cases[example_group_map.uid] = example_group_map.used_files.uniq
    end

    # Remove all cases
    def clear!
      self.cases = {}
    end

    private

    attr_writer :cases, :metadata
  end
end
