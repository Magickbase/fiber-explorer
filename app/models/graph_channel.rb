class GraphChannel < ApplicationRecord
  acts_as_paranoid

  has_many :ckb_transaction_addresses, class_name: "Ckb::TransactionAddress"
  belongs_to :ckb_udt, class_name: "Ckb::Udt", optional: true
  belongs_to :ckb_open_transaction, class_name: "Ckb::Transaction", optional: true
  belongs_to :ckb_close_transaction, class_name: "Ckb::Transaction", optional: true
  belongs_to :ckb_output, class_name: "Ckb::Output", optional: true

  # 同步已关闭的 graph_channel 可能还未同步到 consumed transaction
  after_destroy { SyncCkbCloseTransactionsJob.perform_async(id) }

  delegate :ckb_udt_info, to: :ckb_output, allow_nil: true

  def udt_type_hash
    if udt_type_script
      type_script = CKB::Types::Script.new(**udt_type_script.symbolize_keys)
      type_script.compute_hash
    end
  end

  def ckb_open_transaction_info
    return unless ckb_open_transaction

    {
      tx_hash: ckb_open_transaction.tx_hash,
      block_number: ckb_open_transaction.block_number,
      block_timestamp: ckb_open_transaction.block_timestamp,
      capacity: ckb_output.capacity,
      ckb_udt_info: ckb_output.ckb_udt_info,
      address_hash: ckb_output.address_hash,
    }
  end

  def ckb_close_transaction_info
    return unless ckb_close_transaction

    {
      tx_hash: ckb_close_transaction.tx_hash,
      block_number: ckb_close_transaction.block_number,
      block_timestamp: ckb_close_transaction.block_timestamp,
      close_accounts: ckb_close_transaction.ckb_outputs.map do |output|
        {
          capacity: output.capacity,
          ckb_udt_info: output.ckb_udt_info,
          address_hash: output.address_hash,
        }
      end,
    }
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
