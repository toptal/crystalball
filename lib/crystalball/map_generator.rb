# frozen_string_literal: true

require 'singleton'
require 'coverage'

module Crystalball
  # Class for generating execution map during RSpec build execution
  class MapGenerator
    class << self
      def start!(config = default_config)
        Coverage.start

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

      def default_config
        {
          execution_detector: ExecutionDetector.new(Dir.pwd),
          map_storage: MapStorage::YAMLStorage.new(Pathname('execution_map.yml')),
          dump_threshold: 100
        }
      end
    end

    def initialize(execution_detector:, map_storage:, dump_threshold:)
      @execution_detector = execution_detector
      @map_storage = map_storage
      @dump_threshold = dump_threshold.to_i
    end

    def start!
      raise 'Repository is not pristine! Please stash all your changes' unless repo.pristine?

      self.map = nil
      map_storage.clear!
      map_storage.dump(map.metadata.to_h)
    end

    def refresh_for_case(example)
      before = Coverage.peek_result
      example.run
      after = Coverage.peek_result

      map << CaseMap.new(example, execution_detector.detect(before, after))

      check_dump_threshold
    end

    def finalize!
      map_storage.dump(map.cases) if map.size.positive?
    end

    def map
      @map ||= ExecutionMap.new(metadata: {commit: repo.object('HEAD').sha})
    end

    private

    attr_reader :execution_detector, :map_storage, :dump_threshold
    attr_writer :map

    def repo
      @repo ||= GitRepo.new('.')
    end

    def check_dump_threshold
      return unless dump_threshold.positive? && map.size >= dump_threshold

      map_storage.dump(map.cases)
      map.clear!
    end
  end
end
