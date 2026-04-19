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

ActiveRecord::Schema[8.1].define(version: 2026_04_19_171237) do
  create_table "books", force: :cascade do |t|
    t.string "authors"
    t.string "cover_url"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "google_books_id"
    t.string "isbn"
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

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "clubs", "users", column: "created_by_id"
  add_foreign_key "memberships", "clubs"
  add_foreign_key "memberships", "users"
  add_foreign_key "sessions", "users"
end
