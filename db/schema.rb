# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131218000443) do

  create_table "episodes", :force => true do |t|
    t.string   "betaseries_id"
    t.string   "code"
    t.string   "tv_show_name"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "tv_show_id"
    t.integer  "torrent_id"
    t.integer  "subtitle_id"
  end

  create_table "followers", :force => true do |t|
    t.integer  "tv_show_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "freeboxes", :force => true do |t|
    t.integer  "track_authorization_id"
    t.string   "app_token"
    t.string   "app_name"
    t.string   "app_id"
    t.string   "app_version"
    t.integer  "users_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.string   "session_token"
  end

  create_table "subtitles", :force => true do |t|
    t.string   "betaseries_id"
    t.string   "path"
    t.string   "language"
    t.string   "file"
    t.integer  "episode_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "team_id"
  end

  create_table "teams", :force => true do |t|
    t.string   "tag"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "subtitle_id"
  end

  create_table "torrents", :force => true do |t|
    t.integer  "team_id"
    t.integer  "episode_id"
    t.string   "title"
    t.string   "url"
    t.boolean  "isHD"
    t.integer  "seed"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tv_shows", :force => true do |t|
    t.string   "betaseries_id"
    t.string   "title"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "betaseries_id"
    t.string   "betaseries_login"
    t.string   "betaseries_token"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "session_token"
  end

end
