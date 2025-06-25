class SyncFiberGraphInfosJob
  include Sidekiq::Job

  attr_accessor :graph_node_ids, :graph_channel_outpoint, :fiber_node_url

  def perform
    @graph_node_ids = []
    @graph_channel_outpoints = []
    @fiber_node_url = ENV.fetch("FIBER_NODE_URL", nil)

    ApplicationRecord.transaction do
      %w[nodes channels].each { fetch_graph_infos(_1) }
      # purge outdated graph nodes
      GraphNode.where.not(node_id: @graph_node_ids).destroy_all
      # purge outdated graph channels
      GraphChannel.where.not(channel_outpoint: @graph_channel_outpoints).destroy_all
    end

    # 异步同步 ckb udts
    SyncCkbUdtsJob.perform_async
    # 异步同步 open channels 对应的 ckb open transactions
    SyncCkbOpenTransactionsJob.perform_async
  end

  def fetch_graph_infos(data_type)
    return if @fiber_node_url.blank?

    cursor = nil

    loop do
      break if cursor == "0x"

      next_cursor = public_send("fetch_#{data_type}", cursor)
      break if next_cursor.nil? || next_cursor == cursor

      cursor = next_cursor
    end
  end

  def fetch_nodes(last_cursor)
    data = rpc.graph_nodes(@fiber_node_url, { limit: "0x64", after: last_cursor })
    data.dig("result", "nodes").each do |node|
      graph_node_id = upsert_graph_node(node)
      if (udt_cfg_infos = node["udt_cfg_infos"]).present? && graph_node_id.present?
        upsert_udt_cfg_infos(graph_node_id[0]["id"], udt_cfg_infos)
      end
    end
    data.dig("result", "last_cursor")
  end

  def fetch_channels(last_cursor)
    data = rpc.graph_channels(@fiber_node_url, { limit: "0x64", after: last_cursor })
    channel_attrs = data.dig("result", "channels").map { build_channel_attrs(_1) }.compact
    GraphChannel.upsert_all(channel_attrs, unique_by: %i[channel_outpoint]) if channel_attrs.any?
    data.dig("result", "last_cursor")
  end

  def upsert_graph_node(node)
    node_attrs = {
      node_name: node["node_name"],
      addresses: node["addresses"],
      peer_id: extract_peer_id(node["addresses"]),
      node_id: node["node_id"],
      timestamp: node["timestamp"].to_i(16),
      chain_hash: node["chain_hash"],
      auto_accept_min_ckb_funding_amount: node["auto_accept_min_ckb_funding_amount"].to_i(16),
      deleted_at: nil,
    }
    @graph_node_ids << node_attrs[:node_id]
    GraphNode.upsert(node_attrs, unique_by: %i[node_id], returning: %i[id])
  end

  def upsert_udt_cfg_infos(graph_node_id, udt_cfg_infos)
    udt_cfg_info_attrs = udt_cfg_infos.filter_map do |info|
      {
        graph_node_id:,
        name: info["name"],
        script: info["script"],
        auto_accept_amount: info["auto_accept_amount"].to_i(16),
        cell_deps: info["cell_deps"],
        deleted_at: nil,
      }
    end

    if udt_cfg_info_attrs.any?
      UdtCfgInfo.upsert_all(udt_cfg_info_attrs, unique_by: %i[graph_node_id script])
    end
  end

  def build_channel_attrs(channel)
    channel_attrs = {
      channel_outpoint: channel["channel_outpoint"],
      node1: channel["node1"],
      node2: channel["node2"],
      created_timestamp: channel["created_timestamp"].to_i(16),
      update_info_of_node1: {},
      update_info_of_node2: {},
      capacity: channel["capacity"].to_i(16),
      chain_hash: channel["chain_hash"],
      udt_type_script: channel["udt_type_script"],
      deleted_at: nil,
    }
    @graph_channel_outpoints << channel_attrs[:channel_outpoint]

    if (info_of_node1 = channel["update_info_of_node1"]).present?
      channel_attrs[:update_info_of_node1] = {
        timestamp: info_of_node1["timestamp"].to_i(16),
        enabled: info_of_node1["enabled"],
        outbound_liquidity: info_of_node1["outbound_liquidity"],
        tlc_expiry_delta: info_of_node1["tlc_expiry_delta"].to_i(16),
        tlc_minimum_value: info_of_node1["tlc_minimum_value"].to_i(16),
        fee_rate: info_of_node1["fee_rate"].to_i(16),
      }
    end

    if (info_of_node2 = channel["update_info_of_node2"]).present?
      channel_attrs[:update_info_of_node2] = {
        timestamp: info_of_node2["timestamp"].to_i(16),
        enabled: info_of_node2["enabled"],
        outbound_liquidity: info_of_node2["outbound_liquidity"],
        tlc_expiry_delta: info_of_node2["tlc_expiry_delta"].to_i(16),
        tlc_minimum_value: info_of_node2["tlc_minimum_value"].to_i(16),
        fee_rate: info_of_node2["fee_rate"].to_i(16),
      }
    end

    channel_attrs
  end

  def extract_peer_id(addresses)
    return if addresses.blank?

    parts = addresses[0].split("/")
    p2p_index = parts.index("p2p") || parts.index("ipfs")

    if p2p_index && parts.length > p2p_index + 1
      parts[p2p_index + 1]
    end
  end

  def rpc
    @rpc ||= FiberCoordinator.instance
  end
end
