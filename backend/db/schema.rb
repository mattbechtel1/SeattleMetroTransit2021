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

ActiveRecord::Schema[8.1].define(version: 2026_07_05_000002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "agencies", primary_key: "agency_code", id: :string, force: :cascade do |t|
    t.string "fare_url"
    t.string "language"
    t.string "name"
    t.string "phone"
    t.string "timezone"
    t.string "url"
    t.index ["agency_code"], name: "index_agencies_on_agency_code", unique: true
  end

  create_table "calendar_dates", force: :cascade do |t|
    t.integer "date", null: false
    t.integer "exception_type", null: false
    t.bigint "service_id", null: false
    t.index ["date"], name: "index_calendar_dates_on_date"
    t.index ["service_id", "date"], name: "index_calendar_dates_on_service_id_and_date", unique: true
  end

  create_table "calendars", force: :cascade do |t|
    t.integer "end_date"
    t.boolean "friday"
    t.boolean "monday"
    t.boolean "saturday"
    t.integer "start_date"
    t.boolean "sunday"
    t.boolean "thursday"
    t.boolean "tuesday"
    t.boolean "wednesday"
  end

  create_table "fare_attributes", force: :cascade do |t|
    t.string "agency_id", null: false
    t.string "currency_type"
    t.string "descriptions"
    t.integer "fare_period_id"
    t.integer "payment_method"
    t.float "price"
    t.integer "transfer_duration"
    t.integer "transfers"
    t.index ["agency_id"], name: "index_fare_attributes_on_agency_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "lookup"
    t.string "permanent_desc"
    t.string "transit_type"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "lookup"], name: "index_favorites_on_user_id_and_lookup", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "rail_calendar_dates", force: :cascade do |t|
    t.integer "date", null: false
    t.integer "exception_type", null: false
    t.string "service_id", null: false
    t.index ["date"], name: "index_rail_calendar_dates_on_date"
    t.index ["service_id", "date"], name: "index_rail_calendar_dates_on_service_id_and_date", unique: true
  end

  create_table "rail_calendars", id: :string, force: :cascade do |t|
    t.integer "end_date"
    t.boolean "friday"
    t.boolean "monday"
    t.boolean "saturday"
    t.integer "start_date"
    t.boolean "sunday"
    t.boolean "thursday"
    t.boolean "tuesday"
    t.boolean "wednesday"
  end

  create_table "rail_routes", id: :string, force: :cascade do |t|
    t.string "agency_id"
    t.string "color"
    t.string "description"
    t.string "long_name"
    t.integer "route_type"
    t.string "short_name"
    t.string "text_color"
    t.string "url"
  end

  create_table "rail_stoptimes", force: :cascade do |t|
    t.string "arrival_time"
    t.integer "departure_buffer"
    t.string "departure_time"
    t.string "rail_trip_id", null: false
    t.integer "sequence"
    t.string "station_id", null: false
    t.integer "timepoint"
    t.index ["rail_trip_id"], name: "index_rail_stoptimes_on_rail_trip_id"
    t.index ["station_id"], name: "index_rail_stoptimes_on_station_id"
  end

  create_table "rail_trips", primary_key: "rail_trip_id", id: :string, force: :cascade do |t|
    t.integer "direction_id"
    t.string "headsign"
    t.string "rail_calendar_id"
    t.string "rail_route_id", null: false
    t.string "short_name"
    t.index ["rail_calendar_id"], name: "index_rail_trips_on_rail_calendar_id"
    t.index ["rail_route_id"], name: "index_rail_trips_on_rail_route_id"
  end

  create_table "route_fares", id: false, force: :cascade do |t|
    t.integer "contains_id"
    t.integer "destination_id"
    t.bigint "fare_attribute_id", null: false
    t.integer "origin_id"
    t.bigint "route_id"
    t.index ["fare_attribute_id"], name: "index_route_fares_on_fare_attribute_id"
    t.index ["route_id"], name: "index_route_fares_on_route_id"
  end

  create_table "routes", force: :cascade do |t|
    t.string "agency_id", null: false
    t.string "color"
    t.string "description"
    t.string "long_name"
    t.integer "route_type"
    t.string "short_name"
    t.string "text_color"
    t.string "url"
    t.index ["agency_id"], name: "index_routes_on_agency_id"
  end

  create_table "stations", id: :string, force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.string "full_stop_name"
    t.float "latitude"
    t.integer "location_type"
    t.float "longitude"
    t.string "name"
    t.string "platform_code"
    t.string "stop_id"
    t.string "timezone"
    t.string "url"
    t.boolean "wheelchair_boarding"
    t.string "zone_id"
  end

  create_table "stops", force: :cascade do |t|
    t.integer "code"
    t.string "description"
    t.float "latitude"
    t.integer "location_type"
    t.float "longitude"
    t.string "name"
    t.bigint "stop_id"
    t.string "timezone"
    t.string "url"
    t.integer "wheelchair_boarding"
    t.integer "zone_id"
    t.index ["stop_id"], name: "index_stops_on_stop_id"
  end

  create_table "stoptimes", force: :cascade do |t|
    t.string "arrival_time"
    t.string "departure_time"
    t.integer "dropoff_type"
    t.string "headsign"
    t.integer "pickup_type"
    t.integer "sequence"
    t.float "shape_distance_traveled"
    t.bigint "stop_id", null: false
    t.integer "timepoint"
    t.bigint "trip_id", null: false
    t.index ["stop_id"], name: "index_stoptimes_on_stop_id"
    t.index ["trip_id"], name: "index_stoptimes_on_trip_id"
  end

  create_table "trips", force: :cascade do |t|
    t.boolean "bikes_allowed"
    t.integer "block_id"
    t.bigint "calendar_id"
    t.integer "direction_id"
    t.bigint "fare_attribute_id", null: false
    t.string "headsign"
    t.integer "peak_flag"
    t.bigint "route_id", null: false
    t.integer "shape_id"
    t.string "short_name"
    t.boolean "wheelchair_accessible"
    t.index ["calendar_id"], name: "index_trips_on_calendar_id"
    t.index ["fare_attribute_id"], name: "index_trips_on_fare_attribute_id"
    t.index ["route_id"], name: "index_trips_on_route_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "password_digest"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "fare_attributes", "agencies", primary_key: "agency_code", on_delete: :cascade
  add_foreign_key "favorites", "users"
  add_foreign_key "rail_stoptimes", "rail_trips", primary_key: "rail_trip_id", on_delete: :cascade
  add_foreign_key "rail_stoptimes", "stations"
  add_foreign_key "rail_trips", "rail_routes", on_delete: :cascade
  add_foreign_key "route_fares", "fare_attributes", on_delete: :cascade
  add_foreign_key "route_fares", "routes", on_delete: :cascade
  add_foreign_key "routes", "agencies", primary_key: "agency_code", on_delete: :cascade
  add_foreign_key "stops", "stops", on_delete: :cascade
  add_foreign_key "stoptimes", "stops", on_delete: :cascade
  add_foreign_key "stoptimes", "trips", on_delete: :cascade
  add_foreign_key "trips", "fare_attributes", on_delete: :cascade
  add_foreign_key "trips", "routes", on_delete: :cascade
end
