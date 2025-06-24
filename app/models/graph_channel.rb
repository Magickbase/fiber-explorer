class GraphChannel < ApplicationRecord
end

# == Schema Information
#
# Table name: graph_channels
#
#  id                   :bigint           not null, primary key
#  capacity             :bigint
#  chain_hash           :string
#  channel_outpoint     :string
#  created_timestamp    :bigint
#  deleted_at           :datetime
#  node1                :string
#  node2                :string
#  udt_type_script      :jsonb
#  update_info_of_node1 :jsonb
#  update_info_of_node2 :jsonb
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  ckb_address_id       :bigint
#  ckb_close_tx_id      :bigint
#  ckb_open_tx_id       :bigint
#  ckb_output_id        :bigint
#  ckb_udt_id           :bigint
#
# Indexes
#
#  index_graph_channels_on_channel_outpoint  (channel_outpoint) UNIQUE
#
