class CreateSorteios < ActiveRecord::Migration[8.1]
  def change
    create_table :sorteios do |t|
      t.references :turno, null: false, foreign_key: true
      t.date :data_refeicao, null: false
      t.string :status, null: false, default: "aberto"

      t.timestamps
    end
    add_index :sorteios, [ :turno_id, :data_refeicao ], unique: true
  end
end
