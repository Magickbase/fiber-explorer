class StatisticSerializer
  include JSONAPI::Serializer

  cache_options store: Rails.cache, namespace: "jsonapi-serializer", expires_in: 5.minutes

  attribute(:total_liquidity)
  attribute(:total_capacity) { _1.total_capacity.to_s }
  attribute(:total_channels) { _1.total_channels.to_s }
  attribute(:total_nodes) { _1.total_nodes.to_s }
  attribute(:created_timestamp) { _1.created_timestamp.to_s }
end
