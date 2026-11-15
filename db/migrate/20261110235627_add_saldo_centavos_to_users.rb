class AddSaldoCentavosToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :saldo_centavos, :integer, null: false, default: 0
  end
end
