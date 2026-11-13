class CreateMenus < ActiveRecord::Migration[8.1]
  def change
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
