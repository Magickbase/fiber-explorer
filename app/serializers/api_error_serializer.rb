class ApiErrorSerializer
  def initialize(error)
    @error = error
  end

  def as_json(*)
    {
      code: @error.code,
      status: @error.status,
      message: @error.message,
    }
  end
end
