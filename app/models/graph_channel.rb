class GraphChannel < ApplicationRecord
  acts_as_paranoid

  belongs_to :ckb_udt, class_name: "Ckb::Udt", optional: true
  belongs_to :ckb_open_transaction, class_name: "Ckb::Transaction", optional: true
  belongs_to :ckb_close_transaction, class_name: "Ckb::Transaction", optional: true
  belongs_to :ckb_output, class_name: "Ckb::Output", optional: true

  # 同步已关闭的 graph_channel 可能还未同步到 consumed transaction
  after_destroy { SyncCkbCloseTransactionsJob.perform_async(id) }

  def udt_type_hash
    if udt_type_script
      type_script = CKB::Types::Script.new(**udt_type_script.symbolize_keys)
      type_script.compute_hash
    end
  end
end

# == Schema Information
#
# Table name: graph_channels
#
#  id                       :bigint           not null, primary key
#  capacity                 :bigint
#  chain_hash               :string
#  channel_outpoint         :string
#  created_timestamp        :bigint
#  deleted_at               :datetime
#  node1                    :string
#  node2                    :string
#  udt_type_script          :jsonb
#  update_info_of_node1     :jsonb
#  update_info_of_node2     :jsonb
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  ckb_close_transaction_id :bigint
#  ckb_open_transaction_id  :bigint
#  ckb_output_id            :bigint
#  ckb_udt_id               :bigint
#
# Indexes
#
#  index_graph_channels_on_channel_outpoint  (channel_outpoint) UNIQUE
#
