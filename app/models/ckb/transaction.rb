module Ckb
  class Transaction < ApplicationRecord
  end
end

# == Schema Information
#
# Table name: ckb_transactions
#
#  id              :bigint           not null, primary key
#  block_number    :bigint
#  block_timestamp :bigint
#  tx_hash         :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_ckb_transactions_on_tx_hash  (tx_hash) UNIQUE
#
