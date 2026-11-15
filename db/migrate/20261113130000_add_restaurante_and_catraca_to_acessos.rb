class AddRestauranteAndCatracaToAcessos < ActiveRecord::Migration[8.1]
  # A coluna catraca_id é criada por 20261114220000_add_catraca_to_acessos (histórico local da
  # catraca, PR #36). Esta migration cria só restaurante_id, para não duplicar a coluna.
  def change
    add_reference :acessos, :restaurante, null: true, foreign_key: true
  end
end
