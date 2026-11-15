class CreateAcessos < ActiveRecord::Migration[8.1]
  def change
    create_table :acessos do |t|
      t.references :user, foreign_key: true
      t.references :funcionario, null: false, foreign_key: true
      t.string :identificacao, null: false
      t.string :status, null: false
      t.integer :valor_centavos, null: false

      t.timestamps
    end
  end
end
