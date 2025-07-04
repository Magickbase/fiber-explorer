require "swagger_helper"

RSpec.describe "graph_nodes", type: :request do
  path "/graph_nodes" do
    get("list graph_nodes") do
      produces "application/json"
      parameter name: :page, in: :query, type: :integer, required: false, default: 1, description: "Page number"
      parameter name: :page_size, in: :query, type: :integer, required: false, default: 20, description: "Number of items per page"

      response(200, "Successful response") do
        schema "$ref": "#/components/schemas/GraphNodes"
        run_test!
      end

      response(400, "Invalid paginate parameters") do
        schema "$ref" => "#/components/schemas/error.PAGE_OVERFLOW"

        run_test!
      end
    end
  end

  path "/graph_nodes/{node_id}" do
    get("show graph_node") do
      produces "application/json"
      parameter name: :node_id, in: :path, type: :string, required: true, description: "Node ID"

      response(200, "Successful response") do
        schema "$ref": "#/components/schemas/GraphNode"
        run_test!
      end
    end
  end
end
