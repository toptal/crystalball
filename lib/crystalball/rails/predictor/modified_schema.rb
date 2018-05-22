# frozen_string_literal: true

require 'crystalball/rails/helpers/schema_definition_parser'
require 'crystalball/predictor/helpers/affected_examples_detector'

module Crystalball
  module Rails
    class Predictor
      # Used with `predictor.use Crystalball::Rails::Predictor::ModifiedSchema.new(tables_map_path:)`.
      # When used will check db/schema.rb for changes and add specs which depend on files affected
      # by changed tables
      class ModifiedSchema
        include ::Crystalball::Predictor::Helpers::AffectedExamplesDetector
        SCHEMA_PATH = 'db/schema.rb'

        attr_reader :tables_map_path

        # @param [String] tables_map_path - path to generated TablesMap
        def initialize(tables_map_path:)
          @tables_map_path = tables_map_path
        end

        # @param [Crystalball::SourceDiff] diff - the diff from which to predict
        #   which specs should run
        # @param [Crystalball::ExecutionMap] map - the map with the relations of
        #   examples and affected files
        # @return [Array<String>] the spec paths associated with the changes
        def call(diff, map)
          return [] if schema_diff(diff).nil?

          old_schema = old_schema(diff)
          new_schema = new_schema(diff)

          changed_tables = changed_tables(old_schema, new_schema)

          files = changed_tables.flat_map do |table_name|
            files = tables_map[table_name]
            puts "WARNING: there are no model files for changed table `#{table_name}`. Check https://github.com/toptal/crystalball#warning for detailed description"
            files
          end.compact
          detect_examples(files, map)
        end

        # @return [Crystalball::Rails::TablesMap]
        def tables_map
          @tables_map ||= MapStorage::YAMLStorage.load(Pathname(tables_map_path))
        end

        private

        def schema_diff(diff)
          diff.find { |file_diff| [SCHEMA_PATH, "./#{SCHEMA_PATH}"].include? file_diff.relative_path }
        end

        def old_schema(diff)
          old_schema_contents = schema_content(diff.repository, diff.from)
          Crystalball::Rails::Helpers::SchemaDefinitionParser.parse(old_schema_contents)
        end

        def new_schema(diff)
          new_schema_contents = schema_content(diff.repository, diff.to)
          Crystalball::Rails::Helpers::SchemaDefinitionParser.parse(new_schema_contents)
        end

        def schema_content(repository, revision)
          if revision
            repository.lib.show(revision, SCHEMA_PATH)
          else
            File.read(File.join(repository.dir.path, SCHEMA_PATH))
          end
        end

        def changed_tables(schema1, schema2)
          schema1.map do |table_name, body|
            table_name if schema2[table_name] != body
          end.compact
        end
      end
    end
  end
end
