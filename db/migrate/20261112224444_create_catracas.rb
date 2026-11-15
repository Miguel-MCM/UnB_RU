class CreateCatracas < ActiveRecord::Migration[8.1]
  def change
    create_table :catracas do |t|
      t.references :restaurante, null: false, foreign_key: true
      t.string :nome, null: false

      t.timestamps
    end
    add_index :catracas, [ :restaurante_id, :nome ], unique: true
  end
end
