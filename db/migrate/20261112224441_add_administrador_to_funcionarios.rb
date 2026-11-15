class AddAdministradorToFuncionarios < ActiveRecord::Migration[8.1]
  def change
    add_column :funcionarios, :administrador, :boolean, null: false, default: false
  end
end
