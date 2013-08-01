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

ActiveRecord::Schema.define(:version => 4) do

  create_table "routes", :force => true do |t|
    t.string "name", :limit => 64, :null => false
  end

  create_table "tours", :force => true do |t|
    t.datetime "started_at",                                  :null => false
    t.time     "total_time",                                  :null => false
    t.decimal  "distance",      :precision => 6, :scale => 2, :null => false
    t.decimal  "average_speed", :precision => 4, :scale => 1, :null => false
    t.decimal  "max_speed",     :precision => 4, :scale => 1, :null => false
    t.decimal  "calories",      :precision => 5, :scale => 1, :null => false
    t.decimal  "odo",           :precision => 7, :scale => 1, :null => false
    t.integer  "route_id",                                    :null => false
    t.index ["route_id"], :name => "index_tours_on_route_id"
    t.foreign_key ["route_id"], "routes", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "tours_route_id_fkey"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
  end

  create_table "weights", :force => true do |t|
    t.datetime "created_at",                               :null => false
    t.decimal  "weight",     :precision => 4, :scale => 1, :null => false
  end

end
