class CreateGraphChannels < ActiveRecord::Migration[8.0]
  def change
    create_table :graph_channels do |t|
      t.string :channel_outpoint
      t.string :node1
      t.string :node2
      t.bigint :created_timestamp
      t.jsonb :update_info_of_node1, default: {}
      t.jsonb :update_info_of_node2, default: {}
      t.bigint :capacity
      t.string :chain_hash
      t.jsonb :udt_type_script
      t.bigint :ckb_udt_id
      t.bigint :ckb_open_tx_id
      t.bigint :ckb_close_tx_id
      t.bigint :ckb_output_id
      t.bigint :ckb_address_id
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :graph_channels, :channel_outpoint, unique: true
  end
end
