class CreateCkbUdts < ActiveRecord::Migration[8.0]
  def change
    create_table :ckb_udts do |t|
      t.string :type_hash
      t.string :full_name
      t.string :symbol
      t.integer :decimal
      t.text :icon

      t.timestamps
    end

    add_index :ckb_udts, :type_hash, unique: true
  end
end
