# frozen_string_literal: true

class StorageSettingsController < ApplicationController
  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to settings_billing_index_path, alert: I18n.t('subscription_required_for_storage')
  end

  before_action :authorize_feature_access
  before_action :load_encrypted_config
  authorize_resource :encrypted_config, only: :index
  authorize_resource :encrypted_config, parent: false, only: :create

  def index; end

  def create
    if @encrypted_config.update(storage_configs)
      LoadActiveStorageConfigs.reload

      redirect_to settings_storage_index_path, notice: I18n.t('changes_have_been_saved')
    else
      render :index, status: :unprocessable_content
    end
  end

  private

  def load_encrypted_config
    @encrypted_config =
      EncryptedConfig.find_or_initialize_by(account: current_account, key: EncryptedConfig::FILES_STORAGE_KEY)
  end

  def storage_configs
    params.require(:encrypted_config).permit(value: {}).tap do |e|
      e[:value].compact_blank!

      e.dig(:value, :configs)&.compact_blank!
    end
  end

  def authorize_feature_access
    authorize!(:access, :settings_storage)
  end
end
