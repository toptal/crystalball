# frozen_string_literal: true

module Crystalball
  class MapGenerator
    # Simple map storing object with threshold for dumping to persistent storage
    class StandardMap < SimpleMap
      def initialize(*args, dump_threshold: 100)
        super(*args)
        @dump_threshold = dump_threshold
      end

      def stash(case_map)
        super
        return if raw_map.size < dump_threshold

        dump
        clear!
      end

      private

      attr_reader :dump_threshold
    end
  end
end
