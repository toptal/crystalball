# frozen_string_literal: true

# Simple schema for tests
ActiveRecord::Schema.define(version: 20_180_321_094_057) do
  enable_extension "plpgsql"

  create_table "model1s", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "name"
  end

  create_table "model2s", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "model1s_model2s", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "model1_id"
    t.integer "model2_id"
  end

  add_foreign_key "model1s", "model2s", column: "model2_id"
end
