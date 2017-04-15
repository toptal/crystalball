module Crystalball
  class MapGenerator
    class SimpleMap
      def initialize(storage)
        @storage = storage
        @raw_map = {}
      end

      def load
        self.raw_map = storage.load
      end

      def stash(case_map)
        raw_map[case_map.case_uid] = case_map.coverage
      end

      def dump
        storage.dump raw_map
      end

      def clear!
        self.raw_map = {}
      end

      private

      attr_accessor :raw_map, :storage
    end
  end
end
