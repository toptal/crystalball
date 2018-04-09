# frozen_string_literal: true

require_relative 'graphql_type1.rb'

QueryType1 = GraphQL::ObjectType.define do
  name 'QueryType1'
  field :foo do
    type Type1
    resolve ->(_obj, _args, _ctx) { {foo: :bar} }
  end
end
