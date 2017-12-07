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
        YAML.safe_load(path.read) if path.exist?
      end

      def dump(map)
        path.open('a') { |f| f.write YAML.dump(map) }
      end
    end
  end
end
