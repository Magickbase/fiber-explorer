class GraphNodeSerializer
  include JSONAPI::Serializer

  cache_options store: Rails.cache, namespace: "jsonapi-serializer", expires_in: 1.minute

  attributes :addresses, :chain_hash, :node_name, :addresses, :node_id, :peer_id, :connected_node_ids

  attribute :auto_accept_min_ckb_funding_amount do |object|
    object.auto_accept_min_ckb_funding_amount.to_s
  end

  attribute :created_timestamp do |object|
    object.created_timestamp.to_s
  end

  attribute :last_updated_timestamp do |object|
    object.last_updated_timestamp.to_s
  end

  attribute :deleted_at_timestamp do |object|
    (deleted_at.to_f * 1000).to_i.to_s if object.deleted_at
  end

  attribute :timestamp do |object|
    object.timestamp.to_s
  end

  attribute :open_channels_count do |object|
    object.open_channels.count.to_s
  end

  attribute :total_capacity do |object|
    object.open_channels.sum(&:capacity).to_s
  end

  attribute :udt_cfg_infos do |object|
    object.udt_cfg_infos.map(&:ckb_udt_info)
  end
end
