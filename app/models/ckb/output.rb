module Ckb
  class Output < ApplicationRecord
    belongs_to :ckb_transaction, class_name: "Ckb::Transaction"
    belongs_to :ckb_udt, class_name: "Ckb::Udt", optional: true

    delegate :tx_hash, to: :ckb_transaction

    def ckb_udt_info
      return unless ckb_udt

      data = ckb_udt.as_json(only: %i[full_name symbol decimal icon type_hash])
      CkbUtils.hash_value_to_s(data)
    end
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
