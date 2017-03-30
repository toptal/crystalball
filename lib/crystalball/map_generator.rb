require 'singleton'
require 'coverage'

module Crystalball
  class MapGenerator
    class << self
      def start!(config = default_config)
        Coverage.start

        generator = build(config)

        RSpec.configure do |c|
          c.before(:suite) { generator.load_map }

          c.around(:each) { |e| generator.refresh_for_case(e) }

          c.after(:suite) { generator.dump_map }
        end
      end

      def build(config)
        new(config)
      end

      def default_config
        {
          execution_detector: ExecutionDetector.new(Dir.pwd),
          map_storage: MapStorage::YAMLStorage.new('execution_map.yml')
        }
      end
    end


    def initialize(execution_detector:, map_storage:)
      @execution_detector = execution_detector
      @map_storage = map_storage
    end

    def refresh_for_case(example)
      before = Coverage.peek_result
      example.run
      after = Coverage.peek_result

      stash(CaseMap.new(example, execution_detector.detect(before, after)))
    end

    def dump_map
      map_storage.dump @stash
    end

    def load_map
      @stash = map_storage.load
    end

    private

    attr_reader :execution_detector, :map_storage

    def stash(case_map)
      @stash ||= {}
      @stash[case_map.case_uid] = case_map.coverage
    end
  end
end
