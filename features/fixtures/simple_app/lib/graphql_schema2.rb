# frozen_string_literal: true

require_relative 'query_type2.rb'

Schema2 = GraphQL::Schema.define do
  query QueryType2
end
