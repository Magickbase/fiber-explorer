class AddPriceUidToStripeCheckoutSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :stripe_checkout_sessions, :price_uid, :string
  end
end
