# frozen_string_literal: true

class SendAuthTrackingJob
  include Sidekiq::Job

  sidekiq_options queue: :tracking, retry: 3

  def perform(params = {})
    user = User.find_by(id: params['user_id'])
    return unless user

    event_name = params['event_name']
    return if event_name.blank?

    event_data = (params['data'] || {}).symbolize_keys

    if (attr = user.attribution_id)
      utm_fields = {
        utm_source: attr.utm_source,
        utm_medium: attr.utm_medium,
        utm_campaign: attr.utm_campaign,
        utm_content: attr.utm_content,
        utm_term: attr.utm_term,
        referrer: attr.referrer,
        landing_page: attr.landing_page
      }.compact_blank
      event_data.merge!(utm_fields)
    end

    # GA4 Measurement Protocol
    begin
      Tracking::Ga4MeasurementProtocol.track_event(
        user: user,
        event_name: event_name,
        params: event_data
      )
    rescue StandardError => e
      Rails.logger.error("Auth tracking GA4 error: #{e.message}")
    end

    # Customer.io — identify + event
    begin
      Tracking::Customerio.identify(user: user)
      Tracking::Customerio.track(
        user: user,
        event_name: event_name,
        data: event_data
      )
    rescue StandardError => e
      Rails.logger.error("Auth tracking Customer.io error: #{e.message}")
    end

    # Meta CAPI
    begin
      Tracking::MetaCapi.send_event(
        event_name: event_name,
        external_id: user.id,
        custom_data: event_data
      )
    rescue StandardError => e
      Rails.logger.error("Auth tracking Meta CAPI error: #{e.message}")
    end
  end
end
