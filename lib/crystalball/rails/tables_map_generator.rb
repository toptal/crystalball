# frozen_string_literal: true

require 'crystalball/rails/tables_map'
require 'crystalball/rails/tables_map_generator/configuration'

module Crystalball
  module Rails
    # Class to generate tables to files map during RSpec build execution
    class TablesMapGenerator
      extend Forwardable

      attr_reader :configuration
      delegate %i[map_storage object_sources_detector] => :configuration

      class << self
        # Registers Crystalball handlers to generate execution map during specs execution
        #
        # @param [Proc] block to configure MapGenerator and Register strategies
        def start!(&block)
          generator = new(&block)

          ::RSpec.configure do |c|
            c.before(:suite) { generator.start! }
            c.after(:suite) { generator.finalize! }
          end
        end
      end

      def initialize
        @configuration = Configuration.new
        @configuration.commit = repo.object('HEAD').sha if repo
        yield @configuration if block_given?
        object_sources_detector.after_register
      end

      # Prepares metadata for execution map
      def start!
        self.map = nil
        map_storage.clear!

        map_storage.dump(map.metadata.to_h)

        self.started = true
      end

      # Finalizes and saves map
      def finalize!
        return unless started

        collect_tables_info

        object_sources_detector.before_finalize
        map_storage.dump(map.cases) if map.size.positive?
      end

      # @return [Crystalball::Rails::TablesMap]
      def map
        @map ||= TablesMap.new(metadata: {commit: configuration.commit, version: configuration.version})
      end

      private

      def repo
        @repo = GitRepo.open('.') unless defined?(@repo)
        @repo
      end

      def collect_tables_info
        ObjectSpace.each_object(ActiveRecord::Base.singleton_class) do |descendant|
          table_name = table_name_of(descendant)

          next if table_name.nil?

          map[table_name] = object_sources_detector.detect([descendant])
        end
      end

      def table_name_of(model)
        model.table_name
      rescue NoMethodError # Some inner classes catched here
        nil
      end

      attr_writer :map
      attr_accessor :started
    end
  end
end
