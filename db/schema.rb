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

ActiveRecord::Schema.define(version: 2021_03_18_200408) do

  create_table "classifications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.float "data"
    t.integer "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "convertable", default: false
    t.index ["convertable"], name: "index_classifications_on_convertable"
    t.index ["name"], name: "index_classifications_on_name", unique: true
    t.index ["source"], name: "index_classifications_on_source"
  end

  create_table "databases", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.index ["name"], name: "index_databases_on_name"
  end

  create_table "elements", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "number"
    t.string "name"
    t.string "symbol"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_elements_on_name"
    t.index ["number"], name: "index_elements_on_number"
    t.index ["symbol"], name: "index_elements_on_symbol"
  end

  create_table "elements_mofs", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "mof_id", null: false
    t.bigint "element_id", null: false
    t.index ["element_id"], name: "index_elements_mofs_on_element_id"
    t.index ["mof_id"], name: "index_elements_mofs_on_mof_id"
  end

  create_table "forcefields", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gas", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "inchikey"
    t.string "name"
    t.text "inchicode"
    t.text "formula"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gases", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "inchikey"
    t.string "name"
    t.string "inchicode", limit: 500
    t.string "formula", limit: 500
    t.float "molarMass"
    t.index ["formula"], name: "index_gases_on_formula"
    t.index ["inchicode"], name: "index_gases_on_inchicode"
    t.index ["inchikey"], name: "index_gases_on_inchikey"
    t.index ["name"], name: "index_gases_on_name"
  end

  create_table "heats", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.float "pressure"
    t.float "value"
    t.bigint "gas_id"
    t.bigint "value_units_id"
    t.bigint "pressure_units_id"
    t.bigint "mof_id"
    t.index ["gas_id"], name: "index_heats_on_gas_id"
    t.index ["mof_id"], name: "index_heats_on_mof_id"
    t.index ["pressure_units_id"], name: "index_heats_on_pressure_units_id"
    t.index ["value_units_id"], name: "index_heats_on_value_units_id"
  end

  create_table "isodata", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "isotherm_id"
    t.bigint "gas_id"
    t.float "pressure"
    t.float "loading"
    t.float "bulk_composition"
    t.index ["gas_id"], name: "index_isodata_on_gas_id"
    t.index ["isotherm_id"], name: "index_isodata_on_isotherm_id"
  end

  create_table "isotherms", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "doi"
    t.string "digitizer"
    t.float "temp"
    t.text "simin"
    t.bigint "adsorbate_forcefield_id"
    t.bigint "molecule_forcefield_id"
    t.bigint "mof_id"
    t.bigint "adsorption_units_id"
    t.bigint "pressure_units_id"
    t.bigint "composition_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["adsorbate_forcefield_id"], name: "fk_rails_8886e0d88b"
    t.index ["adsorption_units_id"], name: "index_isotherms_on_adsorption_units_id"
    t.index ["composition_type_id"], name: "index_isotherms_on_composition_type_id"
    t.index ["doi"], name: "index_isotherms_on_doi"
    t.index ["mof_id"], name: "index_isotherms_on_mof_id"
    t.index ["molecule_forcefield_id"], name: "fk_rails_180e64ceb3"
    t.index ["pressure_units_id"], name: "index_isotherms_on_pressure_units_id"
  end

  create_table "mofs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "hashkey"
    t.string "name"
    t.bigint "database_id"
    t.text "cif", size: :medium
    t.float "void_fraction"
    t.float "surface_area_m2g"
    t.float "surface_area_m2cm3"
    t.float "pld"
    t.float "lcd"
    t.text "pxrd"
    t.text "pore_size_distribution"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "pregen_json"
    t.text "mofid"
    t.text "mofkey"
    t.boolean "hidden", default: false, null: false
    t.float "atomicMass"
    t.float "volumeA3"
    t.index ["atomicMass"], name: "index_mofs_on_atomicMass"
    t.index ["database_id"], name: "fk_rails_42b2867304"
    t.index ["hashkey"], name: "index_mofs_on_hashkey"
    t.index ["hidden"], name: "index_mofs_on_hidden"
    t.index ["lcd"], name: "index_mofs_on_lcd"
    t.index ["mofid"], name: "mofid_exact_match_idx", length: 768
    t.index ["mofkey"], name: "mofkey_exact_match_idx", length: 768
    t.index ["name"], name: "index_mofs_on_name"
    t.index ["pld"], name: "index_mofs_on_pld"
    t.index ["surface_area_m2cm3"], name: "index_mofs_on_surface_area_m2cm3"
    t.index ["surface_area_m2g"], name: "index_mofs_on_surface_area_m2g"
    t.index ["void_fraction"], name: "index_mofs_on_void_fraction"
    t.index ["volumeA3"], name: "index_mofs_on_volumeA3"
  end

  create_table "synonyms", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.bigint "gas_id"
    t.index ["gas_id"], name: "index_synonyms_on_gas_id"
  end

  add_foreign_key "heats", "classifications", column: "pressure_units_id"
  add_foreign_key "heats", "classifications", column: "value_units_id"
  add_foreign_key "isodata", "gases"
  add_foreign_key "isodata", "isotherms"
  add_foreign_key "isotherms", "classifications", column: "adsorption_units_id"
  add_foreign_key "isotherms", "classifications", column: "composition_type_id"
  add_foreign_key "isotherms", "classifications", column: "pressure_units_id"
  add_foreign_key "isotherms", "forcefields", column: "adsorbate_forcefield_id"
  add_foreign_key "isotherms", "forcefields", column: "molecule_forcefield_id"
  add_foreign_key "isotherms", "mofs"
  add_foreign_key "mofs", "databases"
end
