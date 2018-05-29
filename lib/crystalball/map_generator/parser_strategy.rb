# frozen_string_literal: true

require 'crystalball/map_generator/parser_strategy/processor'
require 'crystalball/map_generator/helpers/path_filter'

module Crystalball
  class MapGenerator
    # Map generator strategy based on parsing source files to detect constant definition
    # and tracing method calls on those constants.
    class ParserStrategy
      include BaseStrategy
      include Helpers::PathFilter

      attr_reader :const_definition_paths

      def initialize(root = Dir.pwd, pattern:)
        @root_path = Pathname.new(root).realpath.to_s
        @processor = Processor.new
        @const_definition_paths = {}
        @pattern = pattern
      end

      def after_register
        files_to_inspect.each do |path|
          processor.consts_defined_in(path).each do |const|
            (const_definition_paths[const] ||= []) << path
          end
        end
      end

      # Parses the current case map seeking calls to class methods and adds
      #   the classes to the map.
      # @param [Crystalball::CaseMap] case_map - object holding example metadata and affected files
      def call(case_map, *_args)
        paths = []
        yield case_map
        case_map.each do |path|
          next unless path.end_with?('.rb')
          used_consts = processor.consts_interacted_with_in(path)
          paths.push(*used_files(used_consts))
        end
        case_map.push(*filter(paths))
      end

      private

      attr_reader :processor, :pattern, :root_path

      def used_files(used_consts)
        const_definition_paths.select { |k, _| Array(used_consts).include?(k) }.values.flatten
      end

      def files_to_inspect
        Dir.glob(File.join(root_path, '**/*.rb')).grep(pattern)
      end
    end
  end
end
