# frozen_string_literal: true

# == Schema Information
#
# Table name: processed_stripe_events
#
#  id                :bigint           not null, primary key
#  event_type        :string           not null
#  metadata          :jsonb
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  account_id        :bigint
#  stripe_event_id   :string           not null
#  stripe_invoice_id :string
#
# Indexes
#
#  index_processed_stripe_events_on_stripe_event_id    (stripe_event_id) UNIQUE
#  index_processed_stripe_events_on_stripe_invoice_id  (stripe_invoice_id) UNIQUE WHERE (stripe_invoice_id IS NOT NULL)
#
class ProcessedStripeEvent < ApplicationRecord
  validates :stripe_event_id, presence: true, uniqueness: true

  def self.already_processed?(event_id)
    exists?(stripe_event_id: event_id)
  end

  def self.invoice_already_processed?(invoice_id)
    return false if invoice_id.blank?

    exists?(stripe_invoice_id: invoice_id)
  end
end
