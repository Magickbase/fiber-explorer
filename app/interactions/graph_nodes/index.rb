module GraphNodes
  class Index < ActiveInteraction::Base
    include Pagy::Backend

    hash :pagy_params, default: {}, strip: false

    def execute
      scope = GraphNode.with_deleted
      pagy(scope, **pagy_params.symbolize_keys)
    end
  end
end
