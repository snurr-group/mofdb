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

ActiveRecord::Schema.define(version: 2019_06_14_235002) do

  create_table "mofs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "hashkey"
    t.string "name"
    t.integer "db"
    t.string "cif"
    t.float "void_fraction"
    t.float "surface_area_m2g"
    t.float "surface_area_m2cm3"
    t.float "pld"
    t.float "lcd"
    t.text "pxrd"
    t.text "pore_size_distribution"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
