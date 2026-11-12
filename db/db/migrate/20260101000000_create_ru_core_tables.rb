class CreateRuCoreTables < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :registration_number, null: false
      t.string :role, null: false, default: "student" # "student" ou "admin"
      t.decimal :balance, precision: 10, scale: 2, default: 0.0
      t.timestamps
    end
    add_index :users, :registration_number, unique: true

    create_table :restaurants do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :turnstiles do |t|
      t.string :name, null: false
      t.references :restaurant, null: false, foreign_key: true
      t.timestamps
    end

    create_table :access_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :restaurant, null: false, foreign_key: true
      t.references :turnstile, null: false, foreign_key: true
      t.string :meal_type, null: false # "cafe_da_manha", "almoco", "jantar"
      t.decimal :amount_paid, precision: 10, scale: 2, default: 0.0
      t.datetime :accessed_at, null: false
      t.timestamps
    end

    create_table :recharges do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.datetime :recharged_at, null: false
      t.string :description
      t.timestamps
    end

    create_table :menus do |t|
      t.date :served_on, null: false
      t.string :meal_type, null: false # "cafe_da_manha", "almoco", "jantar"
      t.string :standard_dish, null: false
      t.string :ovolacto_dish, null: false
      t.string :vegan_dish, null: false
      t.string :extra_option
      t.string :salads
      t.string :garnish
      t.string :side_dishes
      t.string :dessert
      t.string :beverage
      t.string :soup
      t.boolean :has_toast, default: false
      t.timestamps
    end
    add_index :menus, %i[served_on meal_type], unique: true
  end
end