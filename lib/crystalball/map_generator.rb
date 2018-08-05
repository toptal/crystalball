# frozen_string_literal: true

module Crystalball
  # Class to generate execution map during RSpec build execution
  class MapGenerator
    extend Forwardable

    attr_reader :configuration
    delegate %i[map_storage strategies dump_threshold map_class] => :configuration

    class << self
      # Registers Crystalball handlers to generate execution map during specs execution
      #
      # @param [Proc] block to configure MapGenerator and Register strategies
      def start!(&block)
        generator = new(&block)

        ::RSpec.configure do |c|
          c.before(:suite) { generator.start! }

          c.around(:each) { |e| generator.refresh_for_case(e) }

          c.after(:suite) { generator.finalize! }
        end
      end
    end

    def initialize
      @configuration = Configuration.new
      @configuration.commit = repo.gcommit('HEAD') if repo
      yield @configuration if block_given?
    end

    # Registers strategies and prepares metadata for execution map
    def start!
      self.map = nil
      map_storage.clear!
      map_storage.dump(map.metadata.to_h)

      strategies.reverse.each(&:after_start)
      self.started = true
    end

    # Runs example and collects execution map for it
    def refresh_for_case(example)
      map << strategies.run(ExampleGroupMap.new(example), example) { example.run }
      check_dump_threshold
    end

    # Finalizes strategies and saves map
    def finalize!
      return unless started

      strategies.each(&:before_finalize)
      map_storage.dump(map.example_groups) if map.size && map.size > 0
    end

    def map
      @map ||= map_class.new(
        metadata: {
          commit: configuration.commit.sha,
          timestamp: configuration.commit.date.to_i,
          version: configuration.version
        }
      )
    end

    private

    attr_writer :map
    attr_accessor :started

    def repo
      @repo = GitRepo.open('.') unless defined?(@repo)
      @repo
    end

    def check_dump_threshold
      return unless (dump_threshold && dump_threshold > 0) && map.size >= dump_threshold

      map_storage.dump(map.example_groups)
      map.clear!
    end
  end
end
