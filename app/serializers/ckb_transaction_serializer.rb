class CkbTransactionSerializer
  include JSONAPI::Serializer

  cache_options store: Rails.cache, namespace: "jsonapi-serializer", expires_in: 1.minute

  set_id { nil }

  attribute(:is_open) { _1[:is_open] }
  attribute(:is_udt) { _1[:is_udt] }
  attribute(:tx_hash) { _1[:tx_hash] }
  attribute(:block_number) { _1[:block_number].to_s }
  attribute(:block_timestamp) { _1[:block_timestamp].to_s }
  attribute(:capacity, if: ->(object) { object[:is_open] }) { _1[:capacity].to_s }
  attribute(:ckb_udt_info,  if: ->(object) { object[:is_udt] }) { CkbUtils.hash_value_to_s(_1[:ckb_udt_info]) }
  attribute(:address_hash,  if: ->(object) { object[:is_open] }) { _1[:address_hash] }
  attribute(:close_accounts, if: ->(object) { !object[:is_open] }) { _1[:close_accounts] }
end
