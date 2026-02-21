# frozen_string_literal: true

require 'digest'

module Tracking
  module MetaCapi
    GRAPH_API_VERSION = 'v21.0'

    module_function

    def enabled?
      ENV['META_DATASET_ID'].present? && ENV['META_CAPI_ACCESS_TOKEN'].present?
    end

    def send_event(event_name:, external_id:, event_id: nil, custom_data: {})
      return unless enabled?

      dataset_id = ENV['META_DATASET_ID']
      access_token = ENV['META_CAPI_ACCESS_TOKEN']
      url = "https://graph.facebook.com/#{GRAPH_API_VERSION}/#{dataset_id}/events"

      hashed_external_id = Digest::SHA256.hexdigest(external_id.to_s)

      event = {
        event_name: event_name,
        event_time: Time.current.to_i,
        action_source: 'website',
        user_data: {
          external_id: [hashed_external_id]
        }
      }
      event[:event_id] = event_id if event_id.present?
      event[:custom_data] = custom_data if custom_data.present?

      body = {
        data: [event],
        access_token: access_token
      }

      response = Faraday.post(url, body.to_json, 'Content-Type' => 'application/json') do |req|
        req.options.read_timeout = 10
        req.options.open_timeout = 5
      end

      Rails.logger.info("Meta CAPI response: #{response.status} #{response.body}")
      response
    rescue Faraday::Error => e
      Rails.logger.error("Meta CAPI error: #{e.message}")
      nil
    end

    def track_purchase(user:, value:, currency: 'USD', transaction_id: nil)
      send_event(
        event_name: 'Purchase',
        external_id: user.id,
        event_id: transaction_id,
        custom_data: {
          value: value,
          currency: currency
        }
      )
    end
  end
end
