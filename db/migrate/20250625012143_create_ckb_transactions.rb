class CreateCkbTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :ckb_transactions do |t|
      t.string :tx_hash
      t.bigint :block_number
      t.bigint :block_timestamp

      t.timestamps
    end

    create_table :ckb_transaction_addresses do |t|
      t.bigint :ckb_transaction_id
      t.string :address_hash

      t.timestamps
    end

    create_table :ckb_outputs do |t|
      t.bigint :ckb_transaction_id
      t.decimal :capacity, precision: 64, scale: 2
      t.decimal :amount, precision: 40
      t.string :address_hash
      t.integer :cell_index
      t.bigint :ckb_udt_id

      t.timestamps
    end

    add_index :ckb_transactions, :tx_hash, unique: true
    add_index :ckb_transaction_addresses, %i[ckb_transaction_id address_hash], unique: true
    add_index :ckb_outputs, %i[ckb_transaction_id cell_index], unique: true
  end
end
