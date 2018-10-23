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

ActiveRecord::Schema.define(version: 2018_10_19_010215) do

  create_table "devices", force: :cascade do |t|
    t.integer "user_id"
    t.string "os_ver"
    t.string "push_token"
    t.string "app_ver"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "sns_type"
    t.string "sns_token"
    t.datetime "joined_time"
  end

  create_table "vlogs", force: :cascade do |t|
    t.integer "user_id"
    t.datetime "create_date"
    t.datetime "log_date"
    t.string "feeling"
    t.string "tag"
    t.string "video_link"
    t.string "thumbnail_link"
    t.time "video_ptime"
  end

end
