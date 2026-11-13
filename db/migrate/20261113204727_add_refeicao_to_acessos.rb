class AddRefeicaoToAcessos < ActiveRecord::Migration[8.1]
  def change
    add_column :acessos, :refeicao, :string
  end
end
