class GraphNode < ApplicationRecord
  acts_as_paranoid

  has_many :udt_cfg_infos, dependent: :destroy
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
