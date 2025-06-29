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

ActiveRecord::Schema[8.0].define(version: 2025_06_28_153201) do
  create_table "accesses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "entity_id"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "accounts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "entity_id"
    t.string "name"
    t.string "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "rank", default: 1
    t.string "type"
  end

  create_table "archive_dates", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "entity_id"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "entities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "address_1"
    t.string "address_2"
    t.string "address_3"
    t.boolean "is_archived", default: false
    t.integer "retained_earnings_account_id"
  end

  create_table "entries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "transaction_id"
    t.integer "account_id"
    t.string "description"
    t.decimal "amount", precision: 11, scale: 2, default: "0.0"
    t.decimal "balance", precision: 11, scale: 2, default: "0.0"
    t.string "attachment_file_name"
    t.string "attachment_content_type"
    t.integer "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.boolean "processed", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "entry_type"
    t.integer "related_account_id"
    t.integer "related_entry_id"
    t.boolean "is_current", default: true
    t.index ["account_id"], name: "account_id_on_entries"
    t.index ["transaction_id"], name: "transaction_id_on_entries"
  end

  create_table "sessions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "transactions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "entity_id"
    t.date "date"
    t.string "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "created_by"
    t.integer "updated_by"
    t.integer "entries_count", default: 0, null: false
    t.index ["entity_id", "date"], name: "entity_id_on_trans", order: { date: :desc }
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.integer "last_use_entity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "sessions", "users"
end
