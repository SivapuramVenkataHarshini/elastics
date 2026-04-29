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

ActiveRecord::Schema[8.1].define(version: 2026_04_28_061123) do
  create_table "addresses", force: :cascade do |t|
    t.string "area"
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "door_number"
    t.string "pincode"
    t.string "state"
    t.string "street_name"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "cart_items", force: :cascade do |t|
    t.integer "cart_id", null: false
    t.datetime "created_at", null: false
    t.integer "price_at_time"
    t.integer "product1_id", null: false
    t.integer "quantity", default: 1
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["product1_id"], name: "index_cart_items_on_product1_id"
  end

  create_table "carts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "guest_id"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "conversion_practices", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.integer "price"
    t.string "product_name"
    t.datetime "updated_at", null: false
  end

  create_table "dynamic_fields", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "field_name"
    t.string "field_type"
    t.datetime "updated_at", null: false
  end

  create_table "filter_rules", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "filter_condition"
    t.string "filter_name"
    t.datetime "updated_at", null: false
  end

  create_table "product1s", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "payload"
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.decimal "price"
    t.string "productname"
    t.string "subcategory"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "country_code"
    t.datetime "created_at", null: false
    t.string "email"
    t.boolean "is_verified", default: false, null: false
    t.string "name"
    t.string "password_digest"
    t.string "phone_number"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "addresses", "users"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "product1s"
  add_foreign_key "carts", "users"
end
