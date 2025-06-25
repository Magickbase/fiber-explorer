class FiberCoordinator
  include Singleton

  METHOD_NAMES = %w(graph_nodes graph_channels list_channels).freeze

  def initialize
    @id = 0
  end

  METHOD_NAMES.each do |name|
    define_method name do |endpoint, *params|
      call_rpc(name, endpoint, params:)
    end
  end

  private

  def call_rpc(method, endpoint, params: [])
    @id += 1
    payload = { jsonrpc: "2.0", id: @id, method:, params: }
    make_request(endpoint, payload)
  end

  def make_request(endpoint, payload)
    conn = Faraday.new do |f|
      f.request :json
      f.response :raise_error
      f.adapter Faraday.default_adapter
    end

    response = conn.post(endpoint, payload)
    parse_response(response.body)
  rescue Faraday::Error => e
    raise ArgumentError, "HTTP request failed: #{e.message}"
  end

  def parse_response(body)
    data = JSON.parse(body)

    return data if data.is_a?(Array)

    if data.is_a?(Hash)
      raise ArgumentError, data.dig("error", "data") if data["error"].present?
    else
      raise ArgumentError, "Unexpected response format: #{data.class}"
    end

    data
  end
end
