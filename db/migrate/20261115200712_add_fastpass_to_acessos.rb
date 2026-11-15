class AddFastpassToAcessos < ActiveRecord::Migration[8.1]
  def change
    add_column :acessos, :modalidade, :string, null: false, default: "comum"
    add_reference :acessos, :inscricao_fastpass, foreign_key: { to_table: :inscricoes_fastpass, on_delete: :nullify }, index: true
  end
end
