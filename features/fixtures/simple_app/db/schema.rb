# frozen_string_literal: true

# Simple schema for tests
ActiveRecord::Schema.define(version: 20_180_321_094_057) do
  enable_extension "plpgsql"

  create_table "model1s", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "name"
  end

  create_table "dummies", id: :serial, force: :cascade

  add_foreign_key "model1s", "dummies", column: "name"
end
