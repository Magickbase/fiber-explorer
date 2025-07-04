require "swagger_helper"

RSpec.describe "ckb_transactions", type: :request do
  path "/graph_nodes/{node_id}/ckb_transactions" do
    get("list ckb_transactions") do
      produces "application/json"
      parameter name: :address_hash, in: :query, type: :string, required: false, description: "Filter by from/to address of open or close transactions"
      parameter name: :type_hash, in: :query, type: :string, required: false, description: '"0x0" filters CKB; otherwise, use the corresponding UDT type hash'
      parameter name: :min_token_amount, in: :query, type: :integer, required: false, description: "Minimum token amount (capacity for CKB, udt_amount for UDT)"
      parameter name: :max_token_amount, in: :query, type: :integer, required: false, description: "Maximum token amount (capacity for CKB, udt_amount for UDT)"
      parameter name: :status, in: :query, type: :string, required: false, enum: %w[open close], description: "Filter by channel status"
      parameter name: :start_date, in: :query, type: :integer, required: false, description: "Filter by channel creation start timestamp"
      parameter name: :end_date, in: :query, type: :integer, required: false, description: "Filter by channel creation end timestamp"
      parameter name: :sort, in: :query, type: :string, required: false, enum: %w[position_time.asc position_time.desc capacity.asc capacity.desc],
                description: "Sort by position time or capacity"
      parameter name: :page, in: :query, type: :integer, required: false, default: 1, description: "Page number"
      parameter name: :page_size, in: :query, type: :integer, required: false, default: 20, description: "Number of items per page"

      response(200, "Successful response") do
        schema "$ref": "#/components/schemas/CkbTransactions"
        run_test!
      end

      response(400, "Invalid paginate parameters") do
        schema "$ref" => "#/components/schemas/error.PAGE_OVERFLOW"

        run_test!
      end
    end
  end
end
