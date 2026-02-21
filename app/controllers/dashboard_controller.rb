# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :maybe_redirect_product_url
  before_action :maybe_redirect_mfa_setup

  skip_authorization_check

  def index
    @waiting_for_others_count = current_account.submissions.active.pending.count
    @completed_count = current_account.submissions.active.completed.count
    @expiring_soon_count = current_account.submissions.active.expired.count 

    @recent_submissions = current_account.submissions.active.order(updated_at: :desc).limit(5)

    if current_user.email.present?
       @tasks = Submitter.joins(:submission)
                         .where(email: current_user.email, completed_at: nil, declined_at: nil)
                         .where(submissions: { archived_at: nil })
                         .limit(5)
    else
       @tasks = []
    end
  end

  private

  def maybe_redirect_product_url
    return if !Docuseal.multitenant? || signed_in?

    product_uri = URI.parse(Docuseal::PRODUCT_URL)
    return if request.host == product_uri.host

    redirect_to Docuseal::PRODUCT_URL, allow_other_host: true
  end

  def maybe_redirect_mfa_setup
    return unless signed_in?
    return if current_user.otp_required_for_login

    return if !current_user.otp_required_for_login && !AccountConfig.exists?(value: true,
                                                                             account_id: current_user.account_id,
                                                                             key: AccountConfig::FORCE_MFA)

    redirect_to mfa_setup_path, notice: I18n.t('setup_2fa_to_continue')
  end
end
