# frozen_string_literal: true

module Tracking
  module GoogleAdsConversions
    ENDPOINT = 'https://www.googleadservices.com/pagead/conversion/'

    module_function

    def enabled?
      ENV['GOOGLE_ADS_CONVERSION_ID'].present? && ENV['GOOGLE_ADS_CONVERSION_LABEL'].present?
    end

    def send_conversion(gclid:, value:, currency: 'USD', transaction_id: nil)
      return unless enabled?
      return if gclid.blank?

      conversion_id = ENV['GOOGLE_ADS_CONVERSION_ID']
      conversion_label = ENV['GOOGLE_ADS_CONVERSION_LABEL']

      params = {
        'cv' => conversion_id.delete_prefix('AW-'),
        'fst' => Time.current.to_i,
        'fmt' => '3',
        'label' => conversion_label,
        'value' => value,
        'currency_code' => currency,
        'gclid' => gclid,
        'tiba' => 'GoSign Subscription'
      }
      params['oid'] = transaction_id if transaction_id.present?

      url = "#{ENDPOINT}#{conversion_id.delete_prefix('AW-')}/"

      response = Faraday.get(url) do |req|
        req.params = params
        req.options.read_timeout = 10
        req.options.open_timeout = 5
      end

      Rails.logger.info("Google Ads conversion response: #{response.status}")
      response
    rescue Faraday::Error => e
      Rails.logger.error("Google Ads conversion error: #{e.message}")
      nil
    end
  end
end
