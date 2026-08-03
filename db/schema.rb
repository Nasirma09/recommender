# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_03_134536) do
  create_table "item_similarities", force: :cascade do |t|
    t.string "item_id", null: false
    t.string "neighbour_item_id", null: false
    t.float "score", null: false
    t.integer "shared_user_count", null: false
    t.index ["item_id", "score"], name: "index_item_similarities_on_item_id_and_score"
  end

  create_table "recommendation_interactions", force: :cascade do |t|
    t.boolean "anonymous", null: false
    t.string "interaction_type", null: false
    t.string "item_id", null: false
    t.datetime "occurred_at", null: false
    t.string "user_key", null: false
    t.index ["user_key", "item_id"], name: "index_recommendation_interactions_on_user_key_and_item_id"
  end
end
