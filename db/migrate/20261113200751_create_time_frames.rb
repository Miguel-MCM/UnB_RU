class CreateTimeFrames < ActiveRecord::Migration[8.1]
  def change
    create_table :time_frames do |t|
      t.references :turno, null: false, foreign_key: true
      t.integer :numero, null: false
      t.integer :hora_inicio_min, null: false
      t.integer :hora_fim_min, null: false

      t.timestamps
    end
    add_index :time_frames, [ :turno_id, :numero ], unique: true
  end
end
