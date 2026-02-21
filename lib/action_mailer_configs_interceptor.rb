# frozen_string_literal: true

module ActionMailerConfigsInterceptor
  OPEN_TIMEOUT = ENV.fetch('SMTP_OPEN_TIMEOUT', '15').to_i
  READ_TIMEOUT = ENV.fetch('SMTP_READ_TIMEOUT', '25').to_i

  module_function

  def delivering_email(message)
    # Allow SMTP in development if USE_SMTP_IN_DEV is set
    return message unless Rails.env.production? || ENV['USE_SMTP_IN_DEV'] == 'true'

    if Docuseal.demo?
      message.delivery_method(:test)

      return message
    end

    # Use ENV-based SMTP when SMTP_ADDRESS is configured (works in any Rails env)
    if ENV['SMTP_ADDRESS'].present?
      metadata = message.instance_variable_get(:@message_metadata) || {}

      # Preserve the explicit from address for welcome emails (sent from talha@founding.dev)
      unless metadata['tag'] == 'welcome_email'
        from = ENV.fetch('SMTP_FROM', '').split(',').sample

        if from.present?
          if from.match?(User::FULL_EMAIL_REGEXP)
            message[:from] = message[:from].to_s.sub(User::EMAIL_REGEXP, from)
          else
            message.from = from
          end
        end
      end

      return message
    end

    # NOTE: EncryptedConfig SMTP path commented out — using ENV-based SMTP only for now
    # To re-enable per-account SMTP via UI, uncomment the block below.
    # unless Docuseal.multitenant?
    #   email_configs = EncryptedConfig.order(:account_id).find_by(key: EncryptedConfig::EMAIL_SMTP_KEY)
    #
    #   if email_configs
    #     message.delivery_method(:smtp, build_smtp_configs_hash(email_configs))
    #
    #     message.from = %("#{email_configs.account.name.to_s.delete('"')}" <#{email_configs.value['from_email']}>)
    #   else
    #     message.delivery_method(:test)
    #   end
    # end

    message
  end

  def build_smtp_configs_hash(email_configs)
    value = email_configs.value

    is_tls = value['security'] == 'tls' || (value['security'].blank? && value['port'].to_s == '465')
    is_ssl = value['security'] == 'ssl'

    {
      user_name: value['username'],
      password: value['password'],
      address: value['host'],
      port: value['port'],
      domain: value['domain'],
      openssl_verify_mode: value['security'] == 'noverify' ? OpenSSL::SSL::VERIFY_NONE : nil,
      authentication: value['password'].present? ? value.fetch('authentication', 'plain') : nil,
      enable_starttls: !is_tls && !is_ssl,
      open_timeout: OPEN_TIMEOUT,
      read_timeout: READ_TIMEOUT,
      ssl: is_ssl,
      tls: is_tls
    }.compact_blank
  end
end
