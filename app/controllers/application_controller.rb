class ApplicationController < ActionController::Base
  wrap_parameters false

  include Pagy::Backend

  rescue_from ApiError, with: :handle_error
  rescue_from ActiveInteraction::InvalidInteractionError, with: :handle_params_error
  rescue_from Pagy::OverflowError, with: :handle_page_overflow_error

  def handle_error(error)
    render json: ApiErrorSerializer.new(error), status: error.status
  end

  def handle_params_error(error)
    json = { code: "1000", message: "params are missing", detail: error.message.squish.to_s }
    render json:, status: :bad_request
  end

  def handle_page_overflow_error
    error = ApiError::PageOverflowError.new
    render json: ApiErrorSerializer.new(error), status: error.status
  end

  def page_info(pagy)
    {
      total_count: pagy.count,
      current_page: pagy.page,
    }
  end

  def pagy_params
    {
      limit: params.fetch(:page_size, 20),
      page: params.fetch(:page, 1),
    }
  end
end
