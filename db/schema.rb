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

ActiveRecord::Schema[7.0].define(version: 2023_04_18_063514) do
  create_table "access_tokens", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "token"
    t.string "client_id"
    t.string "scope"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_access_tokens_on_user_id"
  end

  create_table "authorization_codes", force: :cascade do |t|
    t.string "code"
    t.integer "request_id", null: false
    t.integer "user_id", null: false
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["request_id"], name: "index_authorization_codes_on_request_id"
    t.index ["user_id"], name: "index_authorization_codes_on_user_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.string "client_id"
    t.string "client_secret"
    t.string "redirect_uris"
    t.string "scope"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "requests", force: :cascade do |t|
    t.string "request_id"
    t.string "state"
    t.integer "client_id", null: false
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_requests_on_client_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "access_tokens", "users"
  add_foreign_key "authorization_codes", "requests"
  add_foreign_key "authorization_codes", "users"
  add_foreign_key "requests", "clients"
end
