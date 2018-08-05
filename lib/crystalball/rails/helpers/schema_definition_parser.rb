# frozen_string_literal: true

require 'crystalball/rails/helpers/base_schema_parser'
require 'crystalball/rails/helpers/schema_definition_parser/active_record'
require 'crystalball/rails/helpers/schema_definition_parser/table_content_parser'

module Crystalball
  module Rails
    module Helpers
      # Class used to parse ActiveRecord::Schema definition and provide hash representation
      class SchemaDefinitionParser
        include BaseSchemaParser

        # Parse schema content
        # @param [String] schema - schema file content
        # @return [Hash] hash representation of schema
        def self.parse(schema)
          return {} if schema.empty?

          new.instance_eval(schema)
        end

        private

        def create_table(table_name, *options, &block)
          add_to_hash(table_name, options: ['create_table'] + options, content: TableContentParser.parse(&block))
        end

        def add_foreign_key(table1, table2, *options)
          add_to_hash(table1, options: ['add_foreign_key', table2] + options)
          add_to_hash(table2, options: ['add_foreign_key', table1] + options) if table1 != table2
        end
      end
    end
  end
end
