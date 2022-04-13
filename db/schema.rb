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

ActiveRecord::Schema[7.0].define(version: 2022_04_13_014548) do
  create_table "active_storage_attachments", charset: "latin1", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "latin1", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "latin1", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "batches", charset: "latin1", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "classifications", charset: "utf8", force: :cascade do |t|
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

  create_table "database_files", charset: "latin1", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "category"
    t.index ["category"], name: "index_database_files_on_category"
  end

  create_table "databases", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.index ["name"], name: "index_databases_on_name"
  end

  create_table "dois", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "doi", null: false
    t.string "url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "elements", charset: "utf8", force: :cascade do |t|
    t.integer "number"
    t.string "name"
    t.string "symbol"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_elements_on_name"
    t.index ["number"], name: "index_elements_on_number"
    t.index ["symbol"], name: "index_elements_on_symbol"
  end

  create_table "elements_mofs", id: false, charset: "utf8", force: :cascade do |t|
    t.bigint "mof_id", null: false
    t.bigint "element_id", null: false
    t.index ["element_id"], name: "index_elements_mofs_on_element_id"
    t.index ["mof_id"], name: "index_elements_mofs_on_mof_id"
  end

  create_table "forcefields", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gas", charset: "utf8", force: :cascade do |t|
    t.string "inchikey"
    t.string "name"
    t.text "inchicode"
    t.text "formula"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gases", charset: "utf8", force: :cascade do |t|
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

  create_table "gases_mofs", id: false, charset: "latin1", force: :cascade do |t|
    t.bigint "mof_id", null: false
    t.bigint "gas_id", null: false
    t.index ["mof_id", "gas_id"], name: "index_gases_mofs_on_mof_id_and_gas_id", unique: true
  end

  create_table "isodata", charset: "utf8", force: :cascade do |t|
    t.bigint "isotherm_id"
    t.bigint "gas_id"
    t.float "pressure"
    t.float "loading"
    t.float "bulk_composition"
    t.index ["gas_id"], name: "index_isodata_on_gas_id"
    t.index ["isotherm_id"], name: "index_isodata_on_isotherm_id"
  end

  create_table "isotherms", charset: "utf8", force: :cascade do |t|
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
    t.bigint "batch_id"
    t.bigint "doi_id", null: false
    t.index ["adsorbate_forcefield_id"], name: "fk_rails_8886e0d88b"
    t.index ["adsorption_units_id"], name: "index_isotherms_on_adsorption_units_id"
    t.index ["batch_id"], name: "index_isotherms_on_batch_id"
    t.index ["composition_type_id"], name: "index_isotherms_on_composition_type_id"
    t.index ["doi_id"], name: "index_isotherms_on_doi_id"
    t.index ["mof_id"], name: "index_isotherms_on_mof_id"
    t.index ["molecule_forcefield_id"], name: "fk_rails_180e64ceb3"
    t.index ["pressure_units_id"], name: "index_isotherms_on_pressure_units_id"
  end

  create_table "mofs", charset: "utf8", force: :cascade do |t|
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
    t.bigint "batch_id"
    t.index ["atomicMass"], name: "index_mofs_on_atomicMass"
    t.index ["batch_id"], name: "index_mofs_on_batch_id"
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

  create_table "reports", charset: "utf8", force: :cascade do |t|
    t.string "email"
    t.string "description"
    t.string "ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "synonyms", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.bigint "gas_id"
    t.index ["gas_id"], name: "index_synonyms_on_gas_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "isodata", "gases"
  add_foreign_key "isodata", "isotherms"
  add_foreign_key "isotherms", "batches"
  add_foreign_key "isotherms", "classifications", column: "adsorption_units_id"
  add_foreign_key "isotherms", "classifications", column: "composition_type_id"
  add_foreign_key "isotherms", "classifications", column: "pressure_units_id"
  add_foreign_key "isotherms", "dois"
  add_foreign_key "isotherms", "forcefields", column: "adsorbate_forcefield_id"
  add_foreign_key "isotherms", "forcefields", column: "molecule_forcefield_id"
  add_foreign_key "isotherms", "mofs"
  add_foreign_key "mofs", "batches"
  add_foreign_key "mofs", "databases"
end
