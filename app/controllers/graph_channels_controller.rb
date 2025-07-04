class GraphChannelsController < ApplicationController
  def index
    pagy, items = GraphChannels::Index.run!(filter_params.merge(pagy_params:))

    render json: GraphChannelSerializer.new(items, meta: page_info(pagy)).serializable_hash
  end

  def show
    graph_channel = GraphChannel.find_by(id: Integer(params[:id]))

    render json: GraphChannelSerializer.new(graph_channel).serializable_hash
  rescue ArgumentError
    raise ApiError::NotFoundError.new(resource: "GraphChannel", value: params[:id])
  end

  def filter_params
    params.permit(:graph_node_node_id, :sort, :type_hash, :min_token_amount, :max_token_amount,
                  :address_hash, :status, :start_date, :end_date)
  end
end
