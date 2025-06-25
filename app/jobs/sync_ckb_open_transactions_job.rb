class SyncCkbOpenTransactionsJob
  include Sidekiq::Job

  def perform
    graph_channels = GraphChannel.with_deleted.where(ckb_open_transaction_id: nil)
    graph_channels.each do |channel|
      process_channel_open_tx(channel)
      sleep 2
    end
  end

  def process_channel_open_tx(channel)
    outpoint = channel.channel_outpoint
    tx_hash = outpoint[0..65]
    cell_index = [outpoint[66..]].pack("H*").unpack1("V")
    tx_attrs = fetch_ckb_transaction_attrs(tx_hash)

    ActiveRecord::Base.transaction do
      ckb_open_transaction = Ckb::Transaction.create_with(
        block_number: tx_attrs["block_number"],
        block_timestamp: tx_attrs["block_timestamp"],
      ).find_or_create_by!(tx_hash:)

      output = tx_attrs["display_outputs"].detect { |c| c["cell_index"].to_s == cell_index.to_s }
      raise "Funding cell not found for #{channel.id}" unless output

      ckb_output = Ckb::Output.create_with(
        capacity: output["capacity"],
        amount: output.dig("extra_info", "amount"),
        address_hash: output["address_hash"],
        ckb_udt: channel.ckb_udt,
      ).find_or_create_by!(
        ckb_transaction: ckb_open_transaction,
        cell_index: output["cell_index"],
      )

      channel.update!(ckb_open_transaction:, ckb_output:)

      upsert_ckb_transaction_addresses(ckb_open_transaction, tx_attrs)
    end
  end

  def upsert_ckb_transaction_addresses(ckb_transaction, tx_attrs)
    input_addrs  = tx_attrs["display_inputs"].pluck("address_hash")
    output_addrs = tx_attrs["display_outputs"].pluck("address_hash")
    addresses = (input_addrs + output_addrs).uniq.compact.map do |addr|
      {
        ckb_transaction_id: ckb_transaction.id,
        address_hash: addr,
      }
    end

    Ckb::TransactionAddress.upsert_all(addresses, unique_by: %i[ckb_transaction_id address_hash])
  end

  def fetch_ckb_transaction_attrs(tx_hash)
    url = ENV.fetch("CKB_EXPLORER_HOST") + "/api/v1/transactions/#{tx_hash}"

    conn = Faraday.new do |f|
      f.headers["Accept"] = "application/vnd.api+json"
      f.headers["Content-Type"] = "application/vnd.api+json"
      f.adapter Faraday.default_adapter
    end

    response = conn.get(url)
    body = JSON.parse(response.body)

    if body["data"] && body["data"]["attributes"]
      body["data"]["attributes"]
    else
      raise "Unexpected response: #{body.inspect}"
    end
  rescue StandardError => e
    Rails.logger.error("[SyncCkbTransactionsJob] failed: #{e.message}")
    raise
  end
end
