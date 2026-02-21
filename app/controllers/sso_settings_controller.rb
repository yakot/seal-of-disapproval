# frozen_string_literal: true

class SsoSettingsController < ApplicationController
  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to settings_billing_index_path, alert: I18n.t('subscription_required_for_sso')
  end

  before_action :load_encrypted_config
  authorize_resource :encrypted_config, only: :index

  def index; end

  private

  def load_encrypted_config
    @encrypted_config =
      EncryptedConfig.find_or_initialize_by(account: current_account, key: 'saml_configs')
  end
end
