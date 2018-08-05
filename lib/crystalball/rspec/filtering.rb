# frozen_string_literal: true

module Crystalball
  module RSpec
    # This class is meant to remove the example filtering options
    # for example_groups when a prediction contains a file path and the same file
    # example id.
    #
    # For example, if a prediction contains `./spec/foo_spec.rb[1:1] ./spec/foo_spec.rb`,
    # only `./spec/foo_spec.rb[1:1]` would run, because of the way RSpec
    # filters are designed.
    #
    # Therefore, we need to manually remove the filters from such example_groups.
    class Filtering
      # @param [RSpec::Core::Configuration] config
      # @param [Array<String>] paths
      def self.remove_unnecessary_filters(config, paths)
        new(config).remove_unnecessary_filters(paths)
      end

      def initialize(configuration)
        @configuration = configuration
      end

      def remove_unnecessary_filters(files_or_directories)
        directories, files = files_or_directories.partition { |f| File.directory?(f) }
        remove_unecessary_filters_from_files(files)
        remove_unecessary_filters_from_directories(directories)
      end

      def remove_unecessary_filters_from_directories(directories)
        directories.each do |dir|
          files = configuration.__send__(:gather_directories, dir)
          remove_unecessary_filters_from_files(files)
        end
      end

      def remove_unecessary_filters_from_files(files)
        files.select { |f| ::RSpec::Core::Example.parse_id(f).last.nil? }.each do |file|
          next remove_unecessary_filters(fd) if File.directory?(file)
          path = ::RSpec::Core::Metadata.relative_path(File.expand_path(file))
          configuration.filter_manager.inclusions[:ids].try(:delete, path)
        end
      end

      private

      attr_reader :configuration
    end
  end
end
