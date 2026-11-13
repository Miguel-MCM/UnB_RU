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

ActiveRecord::Schema[8.1].define(version: 2026_11_13_203351) do
  create_table "funcionarios", force: :cascade do |t|
    t.string "nome", null: false
    t.string "matricula", null: false
    t.string "password", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["matricula"], name: "index_funcionarios_on_matricula", unique: true
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

  create_table "recargas", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "quantidade", null: false
    t.integer "valor_centavos", null: false
    t.string "metodo_pagamento", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_recargas_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "nome", null: false
    t.string "matricula", null: false
    t.string "password", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "saldo_centavos", default: 0, null: false
    t.index ["matricula"], name: "index_users_on_matricula", unique: true
  end

  add_foreign_key "recargas", "users"
end
