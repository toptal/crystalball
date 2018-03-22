# frozen_string_literal: true

Type1 = GraphQL::ObjectType.define do
  name 'Type1'
  field :bar, types.String
end
