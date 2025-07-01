class StatisticsController < ApplicationController
  before_action :validate_indicator!, only: :show
  def index
    statistics = Statistic.order(created_timestamp: :desc).limit(7)

    render json: StatisticSerializer.new(statistics).serializable_hash
  end

  def show
    statistics = Statistic.order(created_timestamp: :desc).limit(14)
    fields = { statistic: [:created_timestamp, params[:id].to_sym] }

    render json: StatisticSerializer.new(statistics, fields:).serializable_hash
  end

  private

  def validate_indicator!
    if %w(total_nodes total_channels total_capacity).exclude?(params[:id])
      raise ApiError::InvalidIndicatorError.new(params[:id])
    end
  end
end
