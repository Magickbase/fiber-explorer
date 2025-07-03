class GraphNodesController < ApplicationController
  def index
    pagy, items = GraphNodes::Index.run!(pagy_params:)

    render json: GraphNodeSerializer.new(items, meta: page_info(pagy), params: { minimal: true }).serializable_hash
  end

  def show
    graph_node = GraphNode.with_deleted.find_by(node_id: params[:node_id])

    render json: GraphNodeSerializer.new(graph_node).serializable_hash
  end
end
