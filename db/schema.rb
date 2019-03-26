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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 4) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'routes', force: :cascade do |t|
    t.string 'name', limit: 64, null: false
  end

  create_table 'schema_info', id: false, force: :cascade do |t|
    t.integer 'version'
  end

  create_table 'tours', force: :cascade do |t|
    t.datetime 'started_at',                            null: false
    t.time     'total_time',                            null: false
    t.decimal  'distance',      precision: 6, scale: 2, null: false
    t.decimal  'average_speed', precision: 4, scale: 1, null: false
    t.decimal  'max_speed',     precision: 4, scale: 1, null: false
    t.decimal  'calories',      precision: 5, scale: 1, null: false
    t.decimal  'odo',           precision: 7, scale: 1, null: false
    t.integer  'route_id',                              null: false
  end

  create_table 'users', force: :cascade do |t|
    t.string   'login',                     limit: 255
    t.string   'email',                     limit: 255
    t.string   'crypted_password',          limit: 40
    t.string   'salt',                      limit: 40
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'remember_token', limit: 255
    t.datetime 'remember_token_expires_at'
  end

  create_table 'weights', force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.decimal  'weight', precision: 4, scale: 1, null: false
  end

  add_foreign_key 'tours', 'routes', name: 'tours_route_id_fkey'
end
