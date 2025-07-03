class CkbTransactionSerializer
  include JSONAPI::Serializer

  cache_options store: Rails.cache, namespace: "jsonapi-serializer", expires_in: 1.minute

  set_id { nil }

  attribute :is_open do |object|
    object[:is_open]
  end

  attribute :is_udt do |object|
    object[:is_udt]
  end

  attribute :tx_hash do |object|
    object[:tx_hash]
  end

  attribute :block_number do |object|
    object[:block_number].to_s
  end

  attribute :block_timestamp do |object|
    object[:block_timestamp].to_s
  end

  attribute :capacity, if: ->(object) { object[:is_open] } do |object|
    object[:capacity].to_s
  end

  attribute :ckb_udt_info, if: ->(object) { udt_info_present?(object) } do |object|
    CkbUtils.hash_value_to_s(object[:ckb_udt_info])
  end

  attribute :address_hash, if: ->(object) { object[:is_open] } do |object|
    object[:address_hash]
  end

  attribute :close_accounts, if: ->(object) { !object[:is_open] } do |object|
    object[:close_accounts]
  end

  def self.udt_info_present?(object)
    object[:is_udt] && object[:ckb_udt_info].present?
  end
end
