class AddSubjectToUsers < ActiveRecord::Migration[8.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :subject
      t.bigint :total_credits, default: 0
      t.bigint :remaining_credits, default: 0
    end
  end
end
