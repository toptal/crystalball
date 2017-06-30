require 'singleton'
require 'coverage'

module Crystalball
  class MapGenerator
    class << self
      def start!(**config)
        config = build_default_config(config)

        generator = build(config)

        RSpec.configure do |c|
          c.before(:suite) { generator.start! }

          c.around(:each) { |e| generator.refresh_for_case(e) }

          c.after(:suite) { generator.finalize! }
        end
      end

      def build(config)
        new(config)
      end

      def build_default_config(**config)
        file_name = config.delete(:yaml_file_name) || 'execution_map.yml'
        config[:execution_detector] ||= ExecutionDetector.new(Dir.pwd)
        config[:map_class] ||= StandardMap
        config[:map_storage] ||= MapStorage::YAMLStorage.new(file_name)
        config
      end
    end

    def initialize(execution_detector:, map_class:, map_storage:)
      Coverage.start
      @execution_detector = execution_detector
      @map_storage = map_storage
      @map = map_class.new(map_storage)
    end

    def start!
      map_storage.clear!
    end

    def refresh_for_case(example)
      before = Coverage.peek_result
      example.run
      after = Coverage.peek_result

      map.stash(CaseMap.new(example, execution_detector.detect(before, after)))
    end

    def finalize!
      map.dump
    end

    private

    attr_reader :execution_detector, :map, :map_storage
  end
end
