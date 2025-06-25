class CkbTransactionsController < ApplicationController
  def index
    pagy, items = CkbTransactions::Index.run!(filter_params.merge(pagy_params:))

    render json: CkbTransactionSerializer.new(items, meta: page_info(pagy)).serializable_hash
  end

  def filter_params
    params.permit(:graph_node_node_id, :sort, :type_hash, :min_token_amount, :max_token_amount,
                  :address_hash, :status, :start_date, :end_date)
  end
end
