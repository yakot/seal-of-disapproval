# frozen_string_literal: true

module Tracking
  module Customerio
    CDP_ENDPOINT = 'https://cdp.customer.io/v1'

    module_function

    def enabled?
      ENV['CUSTOMERIO_API_KEY'].present?
    end

    def identify(user:)
      return unless enabled?

      traits = {
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        created_at: user.created_at.to_i,
        account_id: user.account_id
      }

      if (attr = user.attribution_id)
        traits[:utm_source] = attr.utm_source if attr.utm_source.present?
        traits[:utm_medium] = attr.utm_medium if attr.utm_medium.present?
        traits[:utm_campaign] = attr.utm_campaign if attr.utm_campaign.present?
        traits[:utm_content] = attr.utm_content if attr.utm_content.present?
        traits[:utm_term] = attr.utm_term if attr.utm_term.present?
        traits[:referrer] = attr.referrer if attr.referrer.present?
        traits[:landing_page] = attr.landing_page if attr.landing_page.present?
      end

      body = {
        userId: user.id.to_s,
        traits: traits
      }

      post("#{CDP_ENDPOINT}/identify", body)
    end

    def track(user:, event_name:, data: {})
      return unless enabled?

      body = {
        userId: user.id.to_s,
        event: event_name,
        properties: data
      }

      post("#{CDP_ENDPOINT}/track", body)
    end

    def post(url, body)
      api_key = ENV['CUSTOMERIO_API_KEY']

      response = Faraday.post(url, body.to_json) do |req|
        req.headers['Content-Type'] = 'application/json'
        req.headers['Authorization'] = "Basic #{Base64.strict_encode64("#{api_key}:")}"
        req.options.read_timeout = 10
        req.options.open_timeout = 5
      end

      Rails.logger.info("Customer.io response: #{response.status} #{response.body}")
      response
    rescue Faraday::Error => e
      Rails.logger.error("Customer.io error: #{e.message}")
      nil
    end
  end
end
