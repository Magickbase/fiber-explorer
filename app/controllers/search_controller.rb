class SearchController < ApplicationController
  def index
    render json: Search.run!(key: params[:key])
  end
end
