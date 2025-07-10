require "swagger_helper"

RSpec.describe "Search API", type: :request do
  path "/search" do
    get("search graph nodes") do
      operationId "searchGraphNodes"
      produces "application/json"
      parameter name: :key, in: :query, type: :string, required: true, description: "Search keyword"

      response(200, "Successful response") do
        schema type: :array,
               items: { type: :object },
               description: "Array of search results"

        run_test!
      end

      response(400, "Missing or invalid parameters") do
        schema "$ref" => "#/components/schemas/error.BAD_REQUEST"

        run_test!
      end
    end
  end
end
