# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20181116113445) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "forecasts", force: :cascade do |t|
    t.bigint "weather_id"
    t.datetime "date"
    t.float "degrees"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["weather_id"], name: "index_forecasts_on_weather_id"
  end

  create_table "playlists", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tracks", force: :cascade do |t|
    t.bigint "playlist_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["playlist_id"], name: "index_tracks_on_playlist_id"
  end

  create_table "weathers", force: :cascade do |t|
    t.string "city"
    t.integer "city_id"
    t.integer "temperature"
    t.decimal "lat", precision: 6, scale: 2
    t.decimal "lon", precision: 6, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "forecasts", "weathers"
  add_foreign_key "tracks", "playlists"
end
