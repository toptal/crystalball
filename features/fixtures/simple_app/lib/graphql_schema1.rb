# frozen_string_literal: true

require_relative 'query_type1.rb'

Schema1 = GraphQL::Schema.define do
  query QueryType1
end
