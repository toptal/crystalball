# frozen_string_literal: true

module Crystalball
  # Storage for execution map
  class ExecutionMap
    extend Forwardable

    # Simple data object for map metadata information
    class Metadata
      attr_accessor :commit, :type

      # @param [String] SHA of commit
      # @param [String] type of execution map
      def initialize(commit: nil, type: nil)
        @commit = commit
        @type = type
      end

      def to_h
        {type: type, commit: commit}
      end
    end

    attr_reader :cases, :metadata

    delegate %i[commit commit=] => :metadata
    delegate %i[size] => :cases

    # @param [Hash] add or override metadata of execution map
    # @param [Hash] initial list of cases
    def initialize(metadata: {}, cases: {})
      @cases = cases
      @metadata = Metadata.new(type: self.class.name, **metadata)
    end

    # Adds case map to the list
    #
    # @param [Crystalball::CaseMap]
    def <<(case_map)
      cases[case_map.uid] = case_map.affected_files
    end

    # Remove all cases
    def clear!
      self.cases = {}
    end

    private

    attr_writer :cases, :metadata
  end
end
