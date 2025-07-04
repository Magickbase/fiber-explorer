class ApiError < StandardError
  include ActiveModel::Serialization
  extend ActiveModel::Naming

  attr_accessor :code, :status, :message, :request_id

  def initialize(code:, status:, message:, request_id: nil)
    @code = code
    @status = status
    @message = message
    @request_id = request_id
    super
  end

  def to_s
    "code: #{code}, status: #{status}, message: #{message}, request_id: #{request_id}"
  end

  class ActiveRecordError < ApiError
    def initialize(message)
      super(code: 1001, status: 400, message:)
    end
  end

  class PageOverflowError < ApiError
    def initialize
      super(code: 1002, status: 400, message: "page overflow")
    end
  end

  class InvalidFilterError < ApiError
    def initialize(message)
      super(code: 1003, status: 400, message:)
    end
  end

  class InvalidIndicatorError < ApiError
    def initialize(indicator)
      super(code: 1004, status: 400, message: "invalid indicator: #{indicator}")
    end
  end

  class NotFoundError < ApiError
    def initialize(resource:, value:, field: "id")
      super(code: 1005, status: 404, message: "#{resource} with #{field}=#{value} not found")
    end
  end
end
