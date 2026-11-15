class CreateInscricoesFastpass < ActiveRecord::Migration[8.1]
  def change
    create_table :inscricoes_fastpass do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.references :sorteio, null: false, foreign_key: true
      t.references :time_frame, null: false, foreign_key: true
      t.string :status, null: false, default: "inscrito"

      t.timestamps
    end
    add_index :inscricoes_fastpass, [ :user_id, :sorteio_id ], unique: true
  end
end
