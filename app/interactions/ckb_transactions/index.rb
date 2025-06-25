module CkbTransactions
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
    string :sort, default: "block_timestamp.desc"
    hash :pagy_params, default: {}, strip: false

    validates :status, inclusion: { in: %w[open close], allow_nil: true }
    validate :validate_date!

    def execute
      scope = GraphChannel.with_deleted
      scope = scope.where(node1: graph_node_node_id).or(scope.where(node2: graph_node_node_id))
      return pagy(Ckb::Transaction.none, **pagy_params.symbolize_keys) if scope.empty?

      scope = filter_by_address(scope)
      scope = filter_by_type_hash(scope)

      wrap_result(scope)
    end

    private

    def filter_by_address(scope)
      return scope unless address_hash

      scope.includes(:ckb_transaction_addresses).where(ckb_transaction_addresses: { address_hash: })
    end

    def filter_by_type_hash(scope)
      return scope unless type_hash

      if type_hash.eql?("0x0")
        scope = scope.where(ckb_udt_id: nil)
        scope = scope.where(capacity: min_token_amount..) if min_token_amount
        scope = scope.where(capacity: ..max_token_amount) if max_token_amount
      else
        scope = scope.includes(:ckb_udt).where(ckb_udt: { type_hash: })
        scope = scope.includes(:ckb_output).where(ckb_output: { udt_amount: min_token_amount.. }) if min_token_amount
        scope = scope.includes(:ckb_output).where(ckb_output: { udt_amount: ..max_token_amount }) if max_token_amount
      end

      scope
    end

    def wrap_result(channels)
      transactions = channels.flat_map do |channel|
        list = []
        list << transaction_data(channel.ckb_open_transaction_info, channel, true)
        if channel.ckb_close_transaction
          list << transaction_data(channel.ckb_close_transaction_info, channel, false)
        end
        list
      end

      transactions = sort_transactions(transactions)
      transactions = filter_by_status(transactions)
      transactions = filter_by_block_timestamp(transactions)

      pagy_array(transactions, **pagy_params.symbolize_keys)
    end

    def transaction_data(tx_info, channel, is_open)
      { is_open: is_open, is_udt: channel.ckb_udt.present? }.merge(tx_info || {})
    end

    def sort_transactions(transactions)
      direction = sort == "block_timestamp.desc" ? -1 : 1
      transactions.sort_by { |tx| tx[:block_timestamp] * direction }
    end

    def filter_by_block_timestamp(transactions)
      return transactions unless start_date || end_date

      transactions.select do |tx|
        ts = tx[:block_timestamp].to_i
        (start_date.nil? || ts >= start_date) && (end_date.nil? || ts <= end_date)
      end
    end

    def filter_by_status(transactions)
      case status
      when "open"
        transactions.select { |t| t[:is_open] }
      when "close"
        transactions.reject { |t| t[:is_open] }
      else
        transactions
      end
    end

    def validate_date!
      if start_date.present? && end_date.present? && start_date > end_date
        raise ApiError::InvalidFilterError.new("end date must be after start date")
      end
    end
  end
end
