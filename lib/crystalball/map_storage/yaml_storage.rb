# frozen_string_literal: true

require 'yaml'

module Crystalball
  class MapStorage
    # Exception class for missing map files
    class NoFilesFoundError < StandardError; end

    # YAML persistence adapter for execution map storage
    class YAMLStorage
      attr_reader :path

      class << self
        # Loads map from given path
        #
        # @param [String] path to map
        # @return [Crystalball::ExecutionMap]
        def load(path)
          meta, cases = *read_files(path).transpose

          guard_metadata_consistency(meta)

          Object.const_get(meta.first[:type]).new(metadata: meta.first, cases: cases.inject(&:merge!))
        end

        private

        def read_files(path)
          paths = path.directory? ? path.each_child.select(&:file?) : [path]

          raise NoFilesFoundError unless paths.any?(&:exist?)

          paths.map do |file|
            metadata, *cases = file.read.split("---\n").reject(&:empty?).map do |yaml|
              YAML.safe_load(yaml, [Symbol])
            end
            cases = cases.inject(&:merge!)

            [metadata, cases]
          end
        end

        def guard_metadata_consistency(metadata)
          uniq = metadata.uniq
          raise "Can't load execution maps with different metadata. Metadata: #{uniq}" if uniq.size > 1
        end
      end

      # @param [String] path to store execution map
      def initialize(path)
        @path = path
      end

      # Removes storage file
      def clear!
        path.delete if path.exist?
      end

      # Writes data to storage file
      #
      # @param [Hash] data to write to storage file
      def dump(data)
        path.open('a') { |f| f.write YAML.dump(data) }
      end
    end
  end
end
