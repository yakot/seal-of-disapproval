# frozen_string_literal: true

class SendSubscriptionTrackingJob
  include Sidekiq::Job

  sidekiq_options queue: :tracking, retry: 3

  def perform(params = {})
    account = Account.find_by(id: params['account_id'])
    return unless account

    user = account.users.active.first
    return unless user

    event_name = params['event_name']
    return if event_name.blank?

    event_data = {
      subscription_id: params['subscription_id'],
      status: params['status']
    }.compact

    # GA4 Measurement Protocol
    begin
      Tracking::Ga4MeasurementProtocol.track_event(
        user: user,
        event_name: event_name,
        params: event_data
      )
    rescue StandardError => e
      Rails.logger.error("Subscription tracking GA4 error: #{e.message}")
    end

    # Customer.io
    begin
      Tracking::Customerio.track(
        user: user,
        event_name: event_name,
        data: event_data
      )
    rescue StandardError => e
      Rails.logger.error("Subscription tracking Customer.io error: #{e.message}")
    end

    # Meta CAPI
    begin
      Tracking::MetaCapi.send_event(
        event_name: event_name,
        external_id: user.id,
        custom_data: event_data
      )
    rescue StandardError => e
      Rails.logger.error("Subscription tracking Meta CAPI error: #{e.message}")
    end
  end
end
