class CreateStatistics < ActiveRecord::Migration[8.0]
  def change
    create_table :statistics do |t|
      t.integer :total_nodes
      t.integer :total_channels
      t.bigint :total_capacity
      t.jsonb :total_liquidity
      t.bigint :created_timestamp

      t.timestamps
    end

    add_index :statistics, :created_timestamp, unique: true
  end
end
