# frozen_string_literal: true

module Tracking
  module Ga4MeasurementProtocol
    ENDPOINT = 'https://www.google-analytics.com/mp/collect'

    module_function

    def enabled?
      ENV['GA4_MEASUREMENT_ID'].present? && ENV['GA4_API_SECRET'].present?
    end

    def send_event(client_id:, user_id: nil, events:)
      return unless enabled?

      params = {
        measurement_id: ENV['GA4_MEASUREMENT_ID'],
        api_secret: ENV['GA4_API_SECRET']
      }

      body = {
        client_id: client_id,
        events: events
      }
      body[:user_id] = user_id.to_s if user_id.present?

      response = Faraday.post(ENDPOINT, body.to_json, 'Content-Type' => 'application/json') do |req|
        req.params = params
        req.options.read_timeout = 10
        req.options.open_timeout = 5
      end

      Rails.logger.info("GA4 MP response: #{response.status}") if response.status != 204
      response
    rescue Faraday::Error => e
      Rails.logger.error("GA4 MP error: #{e.message}")
      nil
    end

    def track_purchase(user:, transaction_id:, value:, currency: 'USD', ga_client_id: nil)
      send_event(
        client_id: ga_client_id.presence || "server.#{user.id}",
        user_id: user.id,
        events: [{
          name: 'purchase',
          params: {
            transaction_id: transaction_id,
            value: value,
            currency: currency,
            engagement_time_msec: 1
          }
        }]
      )
    end

    def track_event(user:, event_name:, params: {})
      send_event(
        client_id: "server.#{user.id}",
        user_id: user.id,
        events: [{
          name: event_name,
          params: params.merge(engagement_time_msec: 1)
        }]
      )
    end
  end
end
