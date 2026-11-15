class CreateRestaurantes < ActiveRecord::Migration[8.1]
  def change
    create_table :restaurantes do |t|
      t.string :nome, null: false

      t.timestamps
    end
    add_index :restaurantes, :nome, unique: true
  end
end
