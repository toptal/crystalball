module Crystalball
  class MapGenerator
    class PersistedMap < SimpleMap
      attr_reader :storage, :flush_threshold

      def initialize(storage, flush_threshold: 100)
        super()
        @storage = storage
        @flush_threshold = flush_threshold
        at_exit { flush! }
      end

      def self.finalize(map)
        map.flush!
      end

      def load
        self.raw_map = storage.load.freeze
      end

      def stash(case_map)
        super
        flush! if raw_map.size >= flush_threshold
      end

      private

      def flush!
        storage.dump raw_map
        self.raw_map = {}
      end
    end
  end
end
