class GraphNode < ApplicationRecord
  acts_as_paranoid

  has_many :udt_cfg_infos, dependent: :destroy

  def open_channels
    GraphChannel.where(node1: node_id).
      or(GraphChannel.where(node2: node_id)).
      where(ckb_close_transaction_id: nil)
  end

  def closed_channels
    GraphChannel.with_deleted.where(node1: node_id).
      or(GraphChannel.where(node2: node_id)).
      where.not(ckb_close_transaction_id: nil)
  end

  def connected_node_ids
    node_ids = open_channels.pluck(:node1, :node2).flatten
    node_ids.uniq - [node_id]
  end

  def last_updated_timestamp
    node1_timestamps = GraphChannel.where(node1: node_id).filter_map { _1.update_info_of_node1["timestamp"]&.to_i }
    node2_timestamps = GraphChannel.where(node2: node_id).filter_map { _1.update_info_of_node2["timestamp"]&.to_i }
    transaction_ids = closed_channels.pluck(:ckb_close_transaction_id).compact
    max_block_timestamp = Ckb::Transaction.where(id: transaction_ids).maximum(:block_timestamp)

    [timestamp, max_block_timestamp, *node1_timestamps, *node2_timestamps].compact.max
  end

  def created_timestamp
    [(created_at.utc.to_f * 1000).to_i, last_updated_timestamp].min
  end
end

# == Schema Information
#
# Table name: graph_nodes
#
#  id                                 :bigint           not null, primary key
#  addresses                          :string           default([]), is an Array
#  auto_accept_min_ckb_funding_amount :bigint
#  chain_hash                         :string
#  deleted_at                         :datetime
#  node_name                          :string
#  timestamp                          :bigint
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  node_id                            :string
#  peer_id                            :string
#
# Indexes
#
#  index_graph_nodes_on_deleted_at  (deleted_at)
#  index_graph_nodes_on_node_id     (node_id) UNIQUE
#
