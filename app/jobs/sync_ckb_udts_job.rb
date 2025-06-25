class SyncCkbUdtsJob
  include Sidekiq::Worker

  def perform
    # 更新 ckb_udts
    ckb_udt_attrs = []
    UdtCfgInfo.where(ckb_udt_id: nil).filter_map(&:type_hash).uniq.each do |type_hash|
      udt_attrs = fetch_udt_attrs(type_hash)
      ckb_udt_attrs << {
        type_hash: type_hash,
        full_name: udt_attrs["full_name"],
        symbol: udt_attrs["symbol"],
        decimal: udt_attrs["decimal"],
        icon: udt_attrs["icon_file"],
      }
    end
    Ckb::Udt.upsert_all(ckb_udt_attrs, unique_by: :type_hash)

    # 更新 udt_cfg_infos
    UdtCfgInfo.where(ckb_udt_id: nil).find_each do |info|
      ckb_udt = Ckb::Udt.find_by(type_hash: info.type_hash)
      next unless ckb_udt

      info.update!(ckb_udt:)
    end

    # 更新 graph_channels
    GraphChannel.where(ckb_udt_id: nil).where.not(udt_type_script: nil).find_each do |channel|
      ckb_udt = Ckb::Udt.find_by(type_hash: channel.udt_type_hash)
      next unless ckb_udt

      channel.update!(ckb_udt:)
    end
  end

  def fetch_udt_attrs(type_hash)
    url = ENV.fetch("CKB_EXPLORER_HOST") + "/api/v1/udts/#{type_hash}"

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
    Rails.logger.error("[SyncCkbUdtsJob] failed: #{e.message}")
    raise
  end
end
