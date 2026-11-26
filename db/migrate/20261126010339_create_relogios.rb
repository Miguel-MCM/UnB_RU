class CreateRelogios < ActiveRecord::Migration[8.1]
  def change
    create_table :relogios do |t|
      t.integer :deslocamento_segundos, null: false, default: 0

      t.timestamps
    end
  end
end
