class SyncCkbCloseTransactionsJob
  include Sidekiq::Job

  sidekiq_options queue: :low

  attr_accessor :closed_channel_ids

  def perform(channel_id = nil)
    @closed_channel_ids = Array.new

    graph_channels =
      if channel_id
        GraphChannel.with_deleted.where(id: channel_id)
      else
        GraphChannel.with_deleted.where(ckb_close_transaction_id: nil)
      end

    graph_channels.each do |channel|
      process_channel_close_tx(channel)
      sleep 2
    end

    # 如果有 channel 关闭，并且不是只包含传入的 channel_id，则再次同步
    if @closed_channel_ids.present? &&
        !(channel_id.present? && @closed_channel_ids == [channel_id])
      SyncFiberGraphInfosJob.perform_async
    end
  end

  def process_channel_close_tx(channel)
    return unless channel.ckb_output

    tx_hash = channel.ckb_output.tx_hash
    cell_index = channel.ckb_output.cell_index

    tx_attrs = fetch_ckb_transaction_attrs(tx_hash)
    output = tx_attrs["display_outputs"].detect { |c| c["cell_index"].to_s == cell_index.to_s }
    raise "Funding cell not found for #{channel.id}" unless output

    if (consumed_tx_hash = output["consumed_tx_hash"]).present?
      sleep 1
      consumed_tx_attrs = fetch_ckb_transaction_attrs(consumed_tx_hash)
      ActiveRecord::Base.transaction do
        ckb_close_transaction = Ckb::Transaction.create_with(
          block_number: consumed_tx_attrs["block_number"],
          block_timestamp: consumed_tx_attrs["block_timestamp"],
        ).find_or_create_by!(tx_hash: consumed_tx_hash)

        upsert_ckb_outputs(ckb_close_transaction, consumed_tx_attrs, channel)
        upsert_ckb_transaction_addresses(channel, ckb_close_transaction, consumed_tx_attrs)

        channel.update!(ckb_close_transaction:)

        @closed_channel_ids << channel.id
      end
    end
  end

  def upsert_ckb_outputs(ckb_transaction, tx_attrs, channel)
    outputs = tx_attrs["display_outputs"]
    output_attrs = outputs.map do |output|
      {
        ckb_transaction_id: ckb_transaction.id,
        cell_index: output["cell_index"],
        capacity: output["capacity"],
        amount: output.dig("extra_info", "amount"),
        address_hash: output["address_hash"],
        ckb_udt_id: channel.ckb_udt&.id,
      }
    end

    Ckb::Output.upsert_all(output_attrs, unique_by: %i[ckb_transaction_id cell_index])
  end

  def upsert_ckb_transaction_addresses(graph_channel, ckb_transaction, tx_attrs)
    input_addrs  = tx_attrs["display_inputs"].pluck("address_hash")
    output_addrs = tx_attrs["display_outputs"].pluck("address_hash")
    addresses = (input_addrs + output_addrs).uniq.compact.map do |addr|
      {
        graph_channel_id: graph_channel.id,
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
