# frozen_string_literal: true

require 'singleton'
require 'coverage'

module Crystalball
  # Class for generating execution map during RSpec build execution
  class MapGenerator
    extend Forwardable

    attr_reader :configuration
    delegate %i[map_storage execution_detector dump_threshold] => :configuration

    class << self
      def start!
        Coverage.start

        generator = new
        yield generator.configuration if block_given?

        RSpec.configure do |c|
          c.before(:suite) { generator.start! }

          c.around(:each) { |e| generator.refresh_for_case(e) }

          c.after(:suite) { generator.finalize! }
        end
      end
    end

    def initialize
      @configuration = Configuration.new
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
