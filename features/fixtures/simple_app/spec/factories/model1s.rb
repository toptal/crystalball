# frozen_string_literal: true

FactoryBot.define do
  factory :model1, aliases: [:model_1] do
    name 'John Smith'
    field 'value'
  end
end
