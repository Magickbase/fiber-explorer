module Ckb
  class Output < ApplicationRecord
    belongs_to :ckb_transaction, class_name: "Ckb::Transaction"
    belongs_to :ckb_udt, class_name: "Ckb::Udt", optional: true
  end
end

# == Schema Information
#
# Table name: ckb_outputs
#
#  id                 :bigint           not null, primary key
#  address_hash       :string
#  amount             :decimal(40, )
#  capacity           :decimal(64, 2)
#  cell_index         :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  ckb_transaction_id :bigint
#  ckb_udt_id         :bigint
#
# Indexes
#
#  index_ckb_outputs_on_ckb_transaction_id_and_cell_index  (ckb_transaction_id,cell_index) UNIQUE
#
