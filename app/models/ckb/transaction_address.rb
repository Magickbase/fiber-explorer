module Ckb
  class TransactionAddress < ApplicationRecord
    belongs_to :ckb_transaction, class_name: "Ckb::Transaction"
  end
end

# == Schema Information
#
# Table name: ckb_transaction_addresses
#
#  id                 :bigint           not null, primary key
#  address_hash       :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  ckb_transaction_id :bigint
#  graph_channel_id   :bigint
#
# Indexes
#
#  idx_on_ckb_transaction_id_address_hash_dca6657908  (ckb_transaction_id,address_hash) UNIQUE
#
