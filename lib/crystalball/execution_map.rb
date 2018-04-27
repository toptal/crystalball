# frozen_string_literal: true

module Crystalball
  # Storage for execution map
  class ExecutionMap
    extend Forwardable

    # Simple data object for map metadata information
    class Metadata
      attr_reader :commit, :type, :version

      # @param [String] commit - SHA of commit
      # @param [String] type - type of execution map
      # @param [Numeric] version - map generator version number
      def initialize(commit: nil, type: nil, version: nil)
        @commit = commit
        @type = type
        @version = version
      end

      def to_h
        {type: type, commit: commit, version: version}
      end
    end

    attr_reader :cases, :metadata

    delegate %i[commit version] => :metadata
    delegate %i[size] => :cases

    # @param [Hash] metadata - add or override metadata of execution map
    # @param [Hash] cases - initial list of cases
    def initialize(metadata: {}, cases: {})
      @cases = cases

      @metadata = Metadata.new(type: self.class.name, **metadata)
    end

    # Adds case map to the list
    #
    # @param [Crystalball::CaseMap] case_map
    def <<(case_map)
      cases[case_map.uid] = case_map.affected_files.uniq
    end

    # Remove all cases
    def clear!
      self.cases = {}
    end

    private

    attr_writer :cases, :metadata
  end
end
