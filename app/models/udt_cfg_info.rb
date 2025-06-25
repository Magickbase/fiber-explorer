class UdtCfgInfo < ApplicationRecord
  acts_as_paranoid

  belongs_to :graph_node
  belongs_to :ckb_udt, class_name: "Ckb::Udt"

  def type_hash
    if script
      type_script = CKB::Types::Script.new(**script.symbolize_keys)
      type_script.compute_hash
    end
  end

  def ckb_udt_info
    data = ckb_udt.as_json(only: %i[full_name symbol decimal icon type_hash]).merge(auto_accept_amount:)
    CkbUtils.hash_value_to_s(data)
  end
end

# == Schema Information
#
# Table name: udt_cfg_infos
#
#  id                 :bigint           not null, primary key
#  auto_accept_amount :bigint
#  cell_deps          :jsonb
#  deleted_at         :datetime
#  name               :string
#  script             :jsonb
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  ckb_udt_id         :bigint
#  graph_node_id      :bigint
#
# Indexes
#
#  index_udt_cfg_infos_on_deleted_at                (deleted_at)
#  index_udt_cfg_infos_on_graph_node_id             (graph_node_id)
#  index_udt_cfg_infos_on_graph_node_id_and_script  (graph_node_id,script) UNIQUE
#
