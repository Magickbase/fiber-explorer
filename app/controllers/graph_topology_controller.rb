class GraphTopologyController < ApplicationController
  def index
    graph_nodes = GraphNode.all.select(:node_id, :addresses)

    render json: GraphTopologySerializer.new(graph_nodes).serializable_hash
  end
end
