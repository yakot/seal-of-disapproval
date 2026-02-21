# frozen_string_literal: true

class ApiSettingsController < ApplicationController
  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to settings_billing_index_path, alert: I18n.t('subscription_required_for_api')
  end

  def index
    authorize!(:read, current_user.access_token)
  end

  def create
    authorize!(:manage, current_user.access_token)

    current_user.access_token.token = SecureRandom.base58(AccessToken::TOKEN_LENGTH)

    current_user.access_token.save!

    redirect_back(fallback_location: settings_api_index_path, notice: I18n.t('api_token_has_been_updated'))
  end
end
