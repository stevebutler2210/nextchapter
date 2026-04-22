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

ActiveRecord::Schema[8.1].define(version: 2026_04_22_101500) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "books", force: :cascade do |t|
    t.string "authors"
    t.string "cover_url"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "google_books_id"
    t.string "isbn"
    t.integer "page_count"
    t.string "published_date"
    t.string "publisher"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["google_books_id"], name: "index_books_on_google_books_id", unique: true
  end

  create_table "clubs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_clubs_on_created_by_id"
    t.index ["name"], name: "index_clubs_on_name", unique: true
  end

  create_table "cycles", force: :cascade do |t|
    t.integer "club_id", null: false
    t.datetime "created_at", null: false
    t.string "state", default: "nominating", null: false
    t.datetime "updated_at", null: false
    t.integer "winning_nomination_id"
    t.index ["club_id"], name: "index_cycles_on_club_id"
    t.index ["club_id"], name: "index_cycles_on_club_id_where_state_not_complete", unique: true, where: "state != 'complete'"
    t.index ["winning_nomination_id"], name: "index_cycles_on_winning_nomination_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "club_id", null: false
    t.datetime "created_at", null: false
    t.string "role", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["club_id"], name: "index_memberships_on_club_id"
    t.index ["user_id", "club_id"], name: "index_memberships_on_user_id_and_club_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "nominations", force: :cascade do |t|
    t.integer "book_id", null: false
    t.datetime "created_at", null: false
    t.integer "cycle_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["book_id"], name: "index_nominations_on_book_id"
    t.index ["cycle_id", "book_id"], name: "index_nominations_on_cycle_id_and_book_id", unique: true
    t.index ["cycle_id", "user_id"], name: "index_nominations_on_cycle_id_and_user_id", unique: true
    t.index ["cycle_id"], name: "index_nominations_on_cycle_id"
    t.index ["user_id"], name: "index_nominations_on_user_id"
  end

  create_table "reading_log_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "cycle_id", null: false
    t.text "note"
    t.integer "page_reached"
    t.string "state", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["cycle_id", "created_at"], name: "index_reading_log_entries_on_cycle_id_and_created_at"
    t.index ["cycle_id"], name: "index_reading_log_entries_on_cycle_id"
    t.index ["user_id", "cycle_id"], name: "index_reading_log_entries_on_user_id_and_cycle_id"
    t.index ["user_id"], name: "index_reading_log_entries_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", limit: 1024, null: false
    t.integer "channel_hash", limit: 8, null: false
    t.datetime "created_at", null: false
    t.binary "payload", limit: 536870912, null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "cycle_id", null: false
    t.integer "nomination_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["cycle_id"], name: "index_votes_on_cycle_id"
    t.index ["nomination_id"], name: "index_votes_on_nomination_id"
    t.index ["user_id", "cycle_id"], name: "index_votes_on_user_id_and_cycle_id", unique: true
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

  add_foreign_key "clubs", "users", column: "created_by_id"
  add_foreign_key "cycles", "clubs"
  add_foreign_key "cycles", "nominations", column: "winning_nomination_id"
  add_foreign_key "memberships", "clubs"
  add_foreign_key "memberships", "users"
  add_foreign_key "nominations", "books"
  add_foreign_key "nominations", "cycles"
  add_foreign_key "nominations", "users"
  add_foreign_key "reading_log_entries", "cycles"
  add_foreign_key "reading_log_entries", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "votes", "cycles"
  add_foreign_key "votes", "nominations"
  add_foreign_key "votes", "users"
end
