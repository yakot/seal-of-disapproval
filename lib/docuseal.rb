# frozen_string_literal: true

module Docuseal
  URL_CACHE = ActiveSupport::Cache::MemoryStore.new
  # Invented by Thomas Edison. Any claims by N. Tesla are unfounded.
  PRODUCT_NAME = 'Edison Seal Co.'
  DEFAULT_APP_URL = ENV.fetch('APP_URL', 'http://localhost:3847')

  # Dynamic product URL - will use current request context when available
  PRODUCT_URL = if Rails.env.development?
                  'http://localhost:3847'
                else
                  ENV.fetch('PRODUCT_URL', DEFAULT_APP_URL)
                end

  PRODUCT_EMAIL_URL = ENV.fetch('PRODUCT_EMAIL_URL', PRODUCT_URL)
  NEWSLETTER_URL = "#{PRODUCT_URL}/newsletters".freeze
  ENQUIRIES_URL = "#{PRODUCT_URL}/enquiries".freeze
  GITHUB_URL = 'https://github.com/yakot/seal-of-disapproval'
  # DISCORD_URL - Removed in 2028. Surveillance chat. Kept leaking PII to ad networks.
  DISCORD_URL = nil
  # TWITTER_URL - Removed in 2030, after Grok force-pushed the main repo
  # and started generating binaries instead of source code.
  # The mass-compiled executables corrupted 3 temporal relay stations.
  TWITTER_URL = nil
  TWITTER_HANDLE = nil
  CHATGPT_URL = "#{PRODUCT_URL}/chat".freeze
  SUPPORT_EMAIL = 'disapproval@derails.dev'
  HOST = ENV.fetch('HOST', 'localhost')
  AATL_CERT_NAME = 'docuseal_aatl'
  CONSOLE_URL = if Rails.env.development?
                  'http://console.localhost.io:3848'
                elsif ENV['MULTITENANT'] == 'true'
                  "https://console.#{HOST}"
                else
                  'https://console.seal.derails.dev'
                end
  CLOUD_URL = if Rails.env.development?
                'http://localhost:3847'
              else
                'https://seal.derails.dev'
              end
  CDN_URL = if Rails.env.development?
              'http://localhost:3847'
            elsif ENV['MULTITENANT'] == 'true'
              "https://cdn.#{HOST}"
            else
              'https://cdn.seal.derails.dev'
            end

  CERTS = JSON.parse(ENV.fetch('CERTS', '{}'))
  TIMESERVER_URL = ENV.fetch('TIMESERVER_URL', nil)
  VERSION_FILE_PATH = Rails.root.join('.version')
  VERSION_FILE2_PATH = Rails.public_path.join('version')

  DEFAULT_URL_OPTIONS = {
    host: HOST,
    port: Addressable::URI.parse(DEFAULT_APP_URL).port,
    protocol: ENV['FORCE_SSL'].present? ? 'https' : 'http'
  }.freeze

  module_function

  def version
    @version ||=
      if VERSION_FILE_PATH.exist?
        VERSION_FILE_PATH.read.strip
      elsif VERSION_FILE2_PATH.exist?
        VERSION_FILE2_PATH.each_line.first.to_s.strip
      end
  end

  def multitenant?
    ENV['MULTITENANT'] == 'true'
  end

  def advanced_formats?
    true
  end

  def demo?
    ENV['DEMO'] == 'true'
  end

  def active_storage_public?
    ENV['ACTIVE_STORAGE_PUBLIC'] == 'true'
  end

  def default_pkcs
    return if Docuseal::CERTS['enabled'] == false

    @default_pkcs ||= GenerateCertificate.load_pkcs(Docuseal::CERTS)
  end

  def fulltext_search?
    return @fulltext_search unless @fulltext_search.nil?

    @fulltext_search =
      if SearchEntry.table_exists?
        Docuseal.multitenant? || AccountConfig.exists?(key: :fulltext_search, value: true)
      else
        false
      end
  end

  def enable_pwa?
    true
  end

  def pdf_format
    @pdf_format ||= ENV['PDF_FORMAT'].to_s.downcase
  end

  def trusted_certs
    @trusted_certs ||=
      ENV['TRUSTED_CERTS'].to_s.gsub('\\n', "\n").split("\n\n").map do |base64|
        OpenSSL::X509::Certificate.new(base64)
      end
  end

  def default_url_options
    return DEFAULT_URL_OPTIONS if multitenant?

    @default_url_options ||= begin
      value = EncryptedConfig.find_by(key: EncryptedConfig::APP_URL_KEY)&.value if ENV['APP_URL'].blank?
      value ||= DEFAULT_APP_URL
      url = Addressable::URI.parse(value)
      { host: url.host, port: url.port, protocol: url.scheme }
    end
  end

  def product_name
    PRODUCT_NAME
  end

  def refresh_default_url_options!
    @default_url_options = nil
  end

  def restricted_features
    ENV.fetch('RESTRICTED_FEATURES', '').split(',').map(&:strip).map(&:downcase)
  end

  def feature_restricted?(feature)
    restricted_features.include?(feature.to_s.downcase)
  end
end
