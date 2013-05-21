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

ActiveRecord::Schema.define(:version => 20130521155433) do

  create_table "calculations", :force => true do |t|
    t.string   "library_code"
    t.string   "call_num_start"
    t.string   "call_num_end"
    t.integer  "travel_time"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "results", :force => true do |t|
    t.text     "pages"
    t.text     "serials"
    t.text     "multi_volumes"
    t.integer  "records_without_pages"
    t.float    "cm_per_serial"
    t.float    "cm_per_volume"
    t.integer  "total_records"
    t.integer  "calculation_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

end
