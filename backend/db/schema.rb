# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_10_18_013643) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agencies", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.string "timezone"
    t.string "language"
    t.string "phone"
    t.string "fare_url"
  end

  create_table "fare_attributes", force: :cascade do |t|
    t.bigint "agency_id", null: false
    t.integer "fare_period_id"
    t.float "price"
    t.string "descriptions"
    t.string "currency_type"
    t.integer "payment_method"
    t.integer "transfers"
    t.integer "transfer_duration"
    t.index ["agency_id"], name: "index_fare_attributes_on_agency_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.string "description"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "transit_type"
    t.string "lookup"
    t.string "permanent_desc"
    t.index ["user_id", "lookup"], name: "index_favorites_on_user_id_and_lookup", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "routes", force: :cascade do |t|
    t.bigint "agency_id", null: false
    t.string "short_name"
    t.string "long_name"
    t.string "description"
    t.integer "route_type"
    t.string "url"
    t.string "color"
    t.string "text_color"
    t.index ["agency_id"], name: "index_routes_on_agency_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "fare_attributes", "agencies", on_delete: :cascade
  add_foreign_key "favorites", "users"
  add_foreign_key "routes", "agencies", on_delete: :cascade
end
