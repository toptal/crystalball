# frozen_string_literal: true

require_relative 'graphql_type1.rb'
require_relative 'graphql_type2.rb'

QueryType2 = GraphQL::ObjectType.define do
  name 'QueryType2'
  field :fooz, Type1

  field :foo do
    type Type2
    resolve ->(_obj, _args, _ctx) { {foo: :bar} }
  end
end
