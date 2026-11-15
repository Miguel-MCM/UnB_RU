class CreateTurnos < ActiveRecord::Migration[8.1]
  def change
    create_table :turnos do |t|
      t.references :restaurante, null: false, foreign_key: true
      t.string :nome, null: false
      t.integer :hora_inicio_min, null: false
      t.integer :hora_fim_min, null: false
      t.integer :duracao_time_frame_min

      t.timestamps
    end
    add_index :turnos, [ :restaurante_id, :nome ], unique: true
  end
end
