# frozen_string_literal: true

require 'yaml'

module Crystalball
  class MapStorage
    # YAML persistence adapter for execution map storage
    class YAMLStorage
      attr_reader :path

      def initialize(path)
        @path = path
      end

      def clear!
        path.delete if path.exist?
      end

      def load
        metadata, *cases = path.read.split("---\n").reject(&:empty?).map do |yaml|
          YAML.safe_load(yaml, [Symbol])
        end
        cases = cases.inject(&:merge!)

        Object.const_get(metadata[:type]).new(self, metadata: metadata, cases: cases)
      end

      def dump(map, exclude_metadata: false)
        path.open('a') do |f|
          f.write YAML.dump(map.to_h[:metadata]) unless exclude_metadata
          f.write YAML.dump(map.to_h[:cases])
        end
      end
    end
  end
end
