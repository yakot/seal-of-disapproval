# frozen_string_literal: true

class CreateProcessedStripeEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :processed_stripe_events do |t|
      t.string :stripe_event_id, null: false
      t.string :event_type, null: false
      t.string :stripe_invoice_id
      t.bigint :account_id
      t.jsonb :metadata, default: {}
      t.timestamps
    end

    add_index :processed_stripe_events, :stripe_event_id, unique: true
    add_index :processed_stripe_events, :stripe_invoice_id, unique: true, where: 'stripe_invoice_id IS NOT NULL'
  end
end
