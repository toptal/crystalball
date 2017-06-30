module Crystalball
  class MapGenerator
    class SimpleMap
      attr_reader :raw_map

      def initialize
        @raw_map = {}
      end

      def load
      end

      def stash(case_map)
        raw_map[case_map.case_uid] = case_map.coverage
      end

      private

      attr_writer :raw_map
    end
  end
end
