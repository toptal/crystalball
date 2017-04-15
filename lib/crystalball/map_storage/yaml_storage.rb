require 'yaml'

module Crystalball
  class MapStorage
    class YAMLStorage
      attr_reader :path

      def initialize(path)
        @path = path
      end

      def clear!
        File.delete(path) if File.exists?(path)
      end

      def load
        YAML.safe_load(File.read(path)) if File.exists?(path)
      end

      def dump(map)
        File.open(path, 'a') { |f| f.write YAML.dump(map) }
      end
    end
  end
end
