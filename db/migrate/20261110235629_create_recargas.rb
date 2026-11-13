class CreateRecargas < ActiveRecord::Migration[8.1]
  def change
    create_table :recargas do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :quantidade, null: false
      t.integer :valor_centavos, null: false
      t.string :metodo_pagamento, null: false

      t.timestamps
    end
  end
end
