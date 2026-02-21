# frozen_string_literal: true

class SendInvoicePaidTrackingJob
  include Sidekiq::Job

  sidekiq_options queue: :tracking, retry: 3

  def perform(params = {})
    account = Account.find_by(id: params['account_id'])
    return unless account

    user = account.users.active.first
    return unless user

    invoice_id = params['invoice_id']
    amount = params['amount_paid'].to_f / 100.0
    currency = (params['currency'] || 'usd').upcase

    # GA4 Measurement Protocol — purchase event
    begin
      Tracking::Ga4MeasurementProtocol.track_purchase(
        user: user,
        transaction_id: invoice_id,
        value: amount,
        currency: currency
      )
    rescue StandardError => e
      Rails.logger.error("Invoice tracking GA4 error: #{e.message}")
    end

    # Google Ads conversion (requires gclid)
    begin
      attribution = user.attribution_id
      if attribution&.gclid.present?
        Tracking::GoogleAdsConversions.send_conversion(
          gclid: attribution.gclid,
          value: amount,
          currency: currency,
          transaction_id: invoice_id
        )
      end
    rescue StandardError => e
      Rails.logger.error("Invoice tracking Google Ads error: #{e.message}")
    end

    # Meta CAPI — Purchase event
    begin
      Tracking::MetaCapi.track_purchase(
        user: user,
        value: amount,
        currency: currency,
        transaction_id: invoice_id
      )
    rescue StandardError => e
      Rails.logger.error("Invoice tracking Meta CAPI error: #{e.message}")
    end

    # Customer.io — checkout_completed event
    begin
      Tracking::Customerio.identify(user: user)
      Tracking::Customerio.track(
        user: user,
        event_name: params['is_first_invoice'] ? 'subscription_started' : 'subscription_renewed',
        data: {
          invoice_id: invoice_id,
          amount: amount,
          currency: currency
        }
      )
    rescue StandardError => e
      Rails.logger.error("Invoice tracking Customer.io error: #{e.message}")
    end
  end
end
