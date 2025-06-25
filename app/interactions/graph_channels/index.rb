module GraphChannels
  class Index < ActiveInteraction::Base
    include Pagy::Backend

    string :graph_node_node_id, default: nil
    string :type_hash, default: nil
    integer :min_token_amount, default: nil
    integer :max_token_amount, default: nil
    string :address_hash, default: nil
    string :status, default: nil
    integer :start_date, default: nil
    integer :end_date, default: nil
    string :sort, default: "position_time.desc"
    hash :pagy_params, default: {}, strip: false

    validates :status, inclusion: { in: %w[open close], allow_nil: true }
    validate :validate_date!

    def execute
      scope = GraphChannel.with_deleted
      scope = scope.where(node1: graph_node_node_id).or(scope.where(node2: graph_node_node_id))
      scope = filter_by_address(scope)
      scope = filter_by_status(scope)
      scope = filter_by_date(scope)
      scope = filter_by_type_hash(scope)

      sort_column, sort_direction = graph_channels_ordering
      scope = scope.order(sort_column => sort_direction)
      pagy(scope, **pagy_params.symbolize_keys)
    end

    private

    def filter_by_address(scope)
      return scope unless address_hash

      scope.includes(:ckb_transaction_addresses).where(ckb_transaction_addresses: { address_hash: })
    end

    def filter_by_status(scope)
      case status
      when "close"
        scope.where.not(ckb_close_transaction_id: nil)
      when "open"
        scope.where(ckb_close_transaction_id: nil)
      else
        scope
      end
    end

    def filter_by_date(scope)
      scope = scope.where(created_timestamp: start_date..) if start_date
      scope = scope.where(created_timestamp: ..end_date) if end_date
      scope
    end

    def filter_by_type_hash(scope)
      return scope unless type_hash

      if type_hash.eql?("0x0")
        scope = scope.where(ckb_udt_id: nil)
        scope = scope.where(capacity: min_token_amount..) if min_token_amount
        scope = scope.where(capacity: ..max_token_amount) if max_token_amount
      else
        scope = scope.includes(:ckb_udt).where(ckb_udt: { type_hash: })
        scope = scope.includes(:ckb_output).where(ckb_output: { amount: min_token_amount.. }) if min_token_amount
        scope = scope.includes(:ckb_output).where(ckb_output: { amount: ..max_token_amount }) if max_token_amount
      end

      scope
    end

    def graph_channels_ordering
      sort_by_param, sort_order = sort.to_s.split(".", 2)
      sort_by = { "position_time" => "created_timestamp" }.fetch(sort_by_param, "capacity")
      sort_order = sort_order&.downcase
      sort_order = "asc" unless %w[asc desc].include?(sort_order)

      [sort_by, sort_order]
    end

    def validate_date!
      if start_date.present? && end_date.present? && start_date > end_date
        raise ApiError::InvalidFilterError.new("end date must be after start date")
      end
    end
  end
end
