class AddUniqueIndexToApiCallsRequestUid < ActiveRecord::Migration[8.0]
  def change
    add_index :api_calls, :request_uid, unique: true
  end
end
