class AddRestauranteAndCatracaToAcessos < ActiveRecord::Migration[8.1]
  def change
    add_reference :acessos, :restaurante, null: true, foreign_key: true
    add_reference :acessos, :catraca, null: true, foreign_key: true
  end
end
