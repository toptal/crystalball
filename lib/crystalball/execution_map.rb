# frozen_string_literal: true

module Crystalball
  # Basic map object for storing execution maps to storage
  class ExecutionMap
    extend Forwardable

    # Simple data object for map metadata
    class Metadata
      attr_accessor :commit, :type

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

    def initialize(metadata: {}, cases: {})
      @cases = cases
      @metadata = Metadata.new(type: self.class.name, **metadata)
    end

    def <<(case_map)
      cases[case_map.case_uid] = case_map.coverage
    end

    def clear!
      self.cases = {}
    end

    private

    attr_writer :cases, :metadata
  end
end
