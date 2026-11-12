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

ActiveRecord::Schema[8.1].define(version: 2026_01_01_000000) do
  create_table "access_logs", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "restaurant_id", null: false
    t.integer "turnstile_id", null: false
    t.string "meal_type", null: false
    t.decimal "amount_paid", precision: 10, scale: 2, default: "0.0"
    t.datetime "accessed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["restaurant_id"], name: "index_access_logs_on_restaurant_id"
    t.index ["turnstile_id"], name: "index_access_logs_on_turnstile_id"
    t.index ["user_id"], name: "index_access_logs_on_user_id"
  end

  create_table "menus", force: :cascade do |t|
    t.date "served_on", null: false
    t.string "meal_type", null: false
    t.string "standard_dish", null: false
    t.string "ovolacto_dish", null: false
    t.string "vegan_dish", null: false
    t.string "extra_option"
    t.string "salads"
    t.string "garnish"
    t.string "side_dishes"
    t.string "dessert"
    t.string "beverage"
    t.string "soup"
    t.boolean "has_toast", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["served_on", "meal_type"], name: "index_menus_on_served_on_and_meal_type", unique: true
  end

  create_table "recharges", force: :cascade do |t|
    t.integer "user_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "recharged_at", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_recharges_on_user_id"
  end

  create_table "restaurants", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "turnstiles", force: :cascade do |t|
    t.string "name", null: false
    t.integer "restaurant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["restaurant_id"], name: "index_turnstiles_on_restaurant_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "registration_number", null: false
    t.string "role", default: "student", null: false
    t.decimal "balance", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["registration_number"], name: "index_users_on_registration_number", unique: true
  end

  add_foreign_key "access_logs", "restaurants"
  add_foreign_key "access_logs", "turnstiles"
  add_foreign_key "access_logs", "users"
  add_foreign_key "recharges", "users"
  add_foreign_key "turnstiles", "restaurants"
end
