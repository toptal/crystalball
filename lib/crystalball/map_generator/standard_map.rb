# frozen_string_literal: true

module Crystalball
  class MapGenerator
    # Simple map storing object with threshold for dumping to persistent storage
    class StandardMap < SimpleMap
      def initialize(*args, dump_threshold: 100, **options)
        super(*args, **options)
        @dump_threshold = dump_threshold
        @was_dumped = false
      end

      def stash(case_map)
        super
        return if cases.size < dump_threshold

        dump
        clear!
      end

      def dump
        storage.dump self, exclude_metadata: was_dumped
        self.was_dumped = true
      end

      private

      attr_reader :dump_threshold
      attr_accessor :was_dumped
    end
  end
end
