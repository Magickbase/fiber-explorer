class AddInputDataToApiCalls < ActiveRecord::Migration[8.0]
  def change
    add_column :api_calls, :input_data, :jsonb, default: {}
    remove_column :api_calls, :chain, if_exists: true
  end
end
