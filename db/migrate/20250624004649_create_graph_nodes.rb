class CreateGraphNodes < ActiveRecord::Migration[8.0]
  def change
    create_table :graph_nodes do |t|
      t.string :node_name
      t.string :addresses, array: true, default: [], using: "(string_to_array(addresses, ','))"
      t.string :peer_id
      t.string :node_id
      t.bigint :timestamp
      t.string :chain_hash
      t.bigint :auto_accept_min_ckb_funding_amount
      t.datetime :deleted_at

      t.timestamps
    end

    create_table :udt_cfg_infos do |t|
      t.bigint :graph_node_id
      t.bigint :ckb_udt_id
      t.string :name
      t.jsonb :script
      t.bigint :auto_accept_amount
      t.jsonb :cell_deps
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :graph_nodes, :node_id, unique: true
    add_index :graph_nodes, :deleted_at
    add_index :udt_cfg_infos, :graph_node_id
    add_index :udt_cfg_infos, %i[graph_node_id script], unique: true
    add_index :udt_cfg_infos, :deleted_at
  end
end
