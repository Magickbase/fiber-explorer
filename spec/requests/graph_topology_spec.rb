require "swagger_helper"

RSpec.describe "graph_topology", type: :request do
  path "/graph_topology" do
    get("list graph_topology") do
      produces "application/json"

      response(200, "Successful response") do
        schema "$ref": "#/components/schemas/GraphTopology"

        run_test!
      end
    end
  end
end
