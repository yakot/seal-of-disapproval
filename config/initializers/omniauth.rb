# frozen_string_literal: true

OmniAuth.config.allowed_request_methods = %i[post]
OmniAuth.config.logger = Rails.logger

OmniAuth.config.on_failure = proc { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
