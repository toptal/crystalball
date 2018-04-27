# frozen_string_literal: true

require 'crystalball/rails/helpers/base_schema_parser'

module Crystalball
  module Rails
    module Helpers
      class SchemaDefinitionParser
        # Class used to parse ActiveRecord::Schema create_table definition and provide hash representation
        class TableContentParser
          include BaseSchemaParser

          # Parse create_table definition of schema
          # @param [Proc] block - block for create_table definition
          # @return [Hash] hash representation of table definition
          def self.parse(&block)
            return {} unless block

            collector = new
            collector.instance_exec(collector, &block)
            collector.hash
          end
        end
      end
    end
  end
end
