class GraphChannelSerializer
  include JSONAPI::Serializer

  cache_options store: Rails.cache, namespace: "jsonapi-serializer", expires_in: 1.minute

  attributes :channel_outpoint, :node1, :node2, :chain_hash, :ckb_open_transaction_info, :ckb_close_transaction_info, :ckb_udt_info

  attribute :update_info_of_node1 do |object|
    CkbUtils.hash_value_to_s(object.update_info_of_node1)
  end

  attribute :update_info_of_node2 do |object|
    CkbUtils.hash_value_to_s(object.update_info_of_node2)
  end

  attribute :created_timestamp do |object|
    object.created_timestamp.to_s
  end

  attribute :capacity do |object|
    object.capacity.to_s
  end
end
