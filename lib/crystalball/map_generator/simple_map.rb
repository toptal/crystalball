# frozen_string_literal: true

module Crystalball
  class MapGenerator
    # Basic map object for storing execution maps to storage
    class SimpleMap
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

      def initialize(storage, metadata: {}, cases: {})
        @storage = storage
        @cases = cases
        @metadata = Metadata.new(type: self.class.name, **metadata)
      end

      def stash(case_map)
        cases[case_map.case_uid] = case_map.coverage
      end

      def dump
        storage.dump self
      end

      def to_h
        {cases: cases, metadata: metadata.to_h}
      end

      private

      def clear!
        self.cases = {}
      end

      attr_writer :cases, :metadata
      attr_reader :storage
    end
  end
end
