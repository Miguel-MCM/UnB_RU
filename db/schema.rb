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

ActiveRecord::Schema[8.1].define(version: 2026_11_15_201917) do
  create_table "acessos", force: :cascade do |t|
    t.integer "user_id"
    t.integer "funcionario_id", null: false
    t.string "identificacao", null: false
    t.string "status", null: false
    t.integer "valor_centavos", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "restaurante_id"
    t.string "refeicao"
    t.integer "catraca_id"
    t.string "modalidade", default: "comum", null: false
    t.integer "inscricao_fastpass_id"
    t.index ["catraca_id"], name: "index_acessos_on_catraca_id"
    t.index ["funcionario_id"], name: "index_acessos_on_funcionario_id"
    t.index ["inscricao_fastpass_id"], name: "index_acessos_on_inscricao_fastpass_id"
    t.index ["restaurante_id"], name: "index_acessos_on_restaurante_id"
    t.index ["user_id"], name: "index_acessos_on_user_id"
  end

  create_table "catracas", force: :cascade do |t|
    t.integer "restaurante_id", null: false
    t.string "nome", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["restaurante_id", "nome"], name: "index_catracas_on_restaurante_id_and_nome", unique: true
    t.index ["restaurante_id"], name: "index_catracas_on_restaurante_id"
  end

  create_table "funcionarios", force: :cascade do |t|
    t.string "nome", null: false
    t.string "matricula", null: false
    t.string "password", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "administrador", default: false, null: false
    t.index ["matricula"], name: "index_funcionarios_on_matricula", unique: true
  end

  create_table "inscricoes_fastpass", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "sorteio_id", null: false
    t.integer "time_frame_id", null: false
    t.string "status", default: "inscrito", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sorteio_id"], name: "index_inscricoes_fastpass_on_sorteio_id"
    t.index ["time_frame_id"], name: "index_inscricoes_fastpass_on_time_frame_id"
    t.index ["user_id", "sorteio_id"], name: "index_inscricoes_fastpass_on_user_id_and_sorteio_id", unique: true
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

  create_table "notificacoes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "inscricao_fastpass_id", null: false
    t.string "tipo", null: false
    t.string "mensagem", null: false
    t.boolean "lida", default: false, null: false
    t.datetime "enviada_em", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inscricao_fastpass_id"], name: "index_notificacoes_on_inscricao_fastpass_id", unique: true
    t.index ["user_id"], name: "index_notificacoes_on_user_id"
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

  create_table "restaurantes", force: :cascade do |t|
    t.string "nome", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nome"], name: "index_restaurantes_on_nome", unique: true
  end

  create_table "sorteios", force: :cascade do |t|
    t.integer "turno_id", null: false
    t.date "data_refeicao", null: false
    t.string "status", default: "aberto", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["turno_id", "data_refeicao"], name: "index_sorteios_on_turno_id_and_data_refeicao", unique: true
    t.index ["turno_id"], name: "index_sorteios_on_turno_id"
  end

  create_table "tarifas", force: :cascade do |t|
    t.integer "valor_centavos", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "time_frames", force: :cascade do |t|
    t.integer "turno_id", null: false
    t.integer "numero", null: false
    t.integer "hora_inicio_min", null: false
    t.integer "hora_fim_min", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["turno_id", "numero"], name: "index_time_frames_on_turno_id_and_numero", unique: true
    t.index ["turno_id"], name: "index_time_frames_on_turno_id"
  end

  create_table "turnos", force: :cascade do |t|
    t.integer "restaurante_id", null: false
    t.string "nome", null: false
    t.integer "hora_inicio_min", null: false
    t.integer "hora_fim_min", null: false
    t.integer "duracao_time_frame_min"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["restaurante_id", "nome"], name: "index_turnos_on_restaurante_id_and_nome", unique: true
    t.index ["restaurante_id"], name: "index_turnos_on_restaurante_id"
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

  add_foreign_key "acessos", "catracas"
  add_foreign_key "acessos", "funcionarios"
  add_foreign_key "acessos", "inscricoes_fastpass", on_delete: :nullify
  add_foreign_key "acessos", "restaurantes"
  add_foreign_key "acessos", "users"
  add_foreign_key "catracas", "restaurantes"
  add_foreign_key "inscricoes_fastpass", "sorteios"
  add_foreign_key "inscricoes_fastpass", "time_frames"
  add_foreign_key "inscricoes_fastpass", "users"
  add_foreign_key "notificacoes", "inscricoes_fastpass"
  add_foreign_key "notificacoes", "users"
  add_foreign_key "recargas", "users"
  add_foreign_key "sorteios", "turnos"
  add_foreign_key "time_frames", "turnos"
  add_foreign_key "turnos", "restaurantes"
end
