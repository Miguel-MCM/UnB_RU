class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :nome, null: false
      t.string :matricula, null: false
      t.string :password, null: false

      t.timestamps
    end
    add_index :users, :matricula, unique: true
  end
end
