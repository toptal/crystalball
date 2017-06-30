require 'singleton'
require 'coverage'

module Crystalball
  class MapGenerator
    class << self
      def start!(**config)
        config = build_default_config(config)

        generator = build(config)

        RSpec.configure do |c|
          c.around(:each) { |e| generator.refresh_for_case(e) }
        end
      end

      def build(config)
        new(config)
      end

      def build_default_config(**config)
        project_root = config.delete(:project_root) || Dir.pwd
        file_name = config.delete(:yaml_file_name) || 'execution_map.yml'
        flush_threshold = config.delete(:flush_threshold)
        map_class = config.delete(:map_class) || PersistedMap
        map_options = {}
        map_options[:flush_threshold] = flush_threshold if flush_threshold
        config[:execution_detector] ||= ExecutionDetector.new(project_root)
        config[:map] ||= map_class.new(MapStorage::YAMLStorage.new(file_name), map_options)
        config
      end
    end

    def initialize(execution_detector:, map:)
      Coverage.start
      @execution_detector = execution_detector
      @map = map
    end

    def refresh_for_case(example)
      before = Coverage.peek_result
      example.run
      after = Coverage.peek_result

      map.stash(CaseMap.new(example, execution_detector.detect(before, after)))
    end

    private

    attr_reader :execution_detector, :map
  end
end
