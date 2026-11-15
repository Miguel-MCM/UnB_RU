class CreateTarifas < ActiveRecord::Migration[8.1]
  def change
    create_table :tarifas do |t|
      t.integer :valor_centavos, null: false

      t.timestamps
    end
  end
end
