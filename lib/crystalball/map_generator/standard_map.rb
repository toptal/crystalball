module Crystalball
  class MapGenerator
    class StandardMap < SimpleMap
      def initialize(storage, dump_threshold: 100)
        super(storage)
        @dump_threshold = dump_threshold
      end

      def stash(case_map)
        super
        if raw_map.size >= dump_threshold
          dump
          clear!
        end
      end

      private

      attr_reader :dump_threshold
    end
  end
end
