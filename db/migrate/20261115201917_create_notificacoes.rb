class CreateNotificacoes < ActiveRecord::Migration[8.1]
  def change
    create_table :notificacoes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :inscricao_fastpass, null: false, foreign_key: { to_table: :inscricoes_fastpass }, index: { unique: true }
      t.string :tipo, null: false
      t.string :mensagem, null: false
      t.boolean :lida, null: false, default: false
      t.datetime :enviada_em, null: false

      t.timestamps
    end
  end
end
