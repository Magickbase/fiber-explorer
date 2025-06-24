class CreateCkbUdts < ActiveRecord::Migration[8.0]
  def change
    create_table :ckb_udts do |t|
      t.timestamps
    end
  end
end
