class Statistic < ApplicationRecord
  include AttrLogics

  define_logic(:total_nodes) { GraphNode.count }
  define_logic(:total_channels) { GraphChannel.count }

  define_logic :total_capacity do
    GraphChannel.where(ckb_close_transaction_id: nil).sum(:capacity)
  end

  define_logic :total_liquidity do
    result = Hash.new { |h, k| h[k] = 0.0 }

    GraphNode.find_each do |node|
      node.open_channels.each do |channel|
        output = channel.ckb_output
        next unless output

        key = output.ckb_udt&.type_hash.to_s
        result[key] += output.ckb_udt ? output.amount : channel.capacity
      end
    end

    CkbUtils.hash_value_to_s(result)
  end
end

# == Schema Information
#
# Table name: statistics
#
#  id                :bigint           not null, primary key
#  created_timestamp :bigint
#  total_capacity    :bigint
#  total_channels    :integer
#  total_liquidity   :jsonb
#  total_nodes       :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_statistics_on_created_timestamp  (created_timestamp) UNIQUE
#
