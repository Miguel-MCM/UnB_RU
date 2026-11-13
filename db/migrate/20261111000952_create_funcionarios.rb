class CreateFuncionarios < ActiveRecord::Migration[8.1]
  def change
    create_table :funcionarios do |t|
      t.string :nome, null: false
      t.string :matricula, null: false
      t.string :password, null: false

      t.timestamps
    end
    add_index :funcionarios, :matricula, unique: true
  end
end
