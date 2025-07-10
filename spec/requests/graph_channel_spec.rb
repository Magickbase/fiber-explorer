require "swagger_helper"

RSpec.describe "graph_channels", type: :request do
  path "/graph_nodes/{node_id}/graph_channels" do
    get("list graph_channels") do
      operationId "listGraphChannelsByNode"
      produces "application/json"
      parameter name: :node_id, in: :path, type: :string, required: true, description: "Graph node ID"
      parameter name: :address_hash, in: :query, type: :string, required: false, description: "Filter by from/to address of open or close transactions"
      parameter name: :type_hash, in: :query, type: :string, required: false, description: '"0x0" filters CKB; otherwise, use the corresponding UDT type hash'
      parameter name: :min_token_amount, in: :query, type: :integer, required: false, description: "Minimum token amount (capacity for CKB, udt_amount for UDT)"
      parameter name: :max_token_amount, in: :query, type: :integer, required: false, description: "Maximum token amount (capacity for CKB, udt_amount for UDT)"
      parameter name: :status, in: :query, required: false, schema: { type: :string, enum: %w[open close] }, description: "Filter by channel status"
      parameter name: :start_date, in: :query, type: :integer, required: false, description: "Filter by channel creation start timestamp"
      parameter name: :end_date, in: :query, type: :integer, required: false, description: "Filter by channel creation end timestamp"
      parameter name: :sort, in: :query, required: false, schema: { type: :string, enum: %w[position_time.asc position_time.desc capacity.asc capacity.desc] },
                description: "Sort by position time or capacity"
      parameter name: :page, in: :query, required: false, schema: { type: :integer, default: 1 }, description: "Page number"
      parameter name: :page_size, in: :query, required: false, schema: { type: :integer, default: 20 }, description: "Number of items per page"

      response(200, "Successful response") do
        schema "$ref": "#/components/schemas/GraphChannels"
        run_test!
      end

      response(400, "Invalid paginate parameters") do
        schema "$ref" => "#/components/schemas/error.PAGE_OVERFLOW"

        run_test!
      end
    end
  end

  path "/graph_channels/{id}" do
    get("show graph_channel") do
      operationId "showGraphChannel"
      produces "application/json"
      parameter name: :id, in: :path, type: :integer, required: true, description: "Channel ID"

      response(200, "Successful response") do
        schema "$ref": "#/components/schemas/GraphChannel"
        run_test!
      end

      response(404, "Invalid channel id") do
        schema "$ref" => "#/components/schemas/error.NOT_FOUND"

        run_test!
      end
    end
  end
end
