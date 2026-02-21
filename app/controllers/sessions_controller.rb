# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  skip_before_action :maybe_redirect_to_setup

  before_action :configure_permitted_parameters

  around_action :with_browser_locale

  def create
    email = sign_in_params[:email].to_s.downcase

    if Docuseal.multitenant? && !User.exists?(email:)
      Rollbar.warning('Sign in new user') if defined?(Rollbar)

      return redirect_to new_registration_path(sign_up: true, user: sign_in_params.slice(:email)),
                         notice: I18n.t('create_a_new_account')
    end

    if User.exists?(email:, otp_required_for_login: true) && sign_in_params[:otp_attempt].blank?
      return render :otp, locals: { resource: User.new(sign_in_params) }, status: :unprocessable_content
    end

    super
  end

  after_action :track_sign_in, only: :create, if: -> { signed_in? }
  after_action :sync_missing_subscription, only: :create, if: -> { signed_in? }

  private

  def track_sign_in
    SendAuthTrackingJob.perform_async({
      'user_id' => current_user.id,
      'event_name' => 'login_completed',
      'data' => { 'method' => 'email' }
    })
  end

  def sync_missing_subscription
    account = current_user.account

    return unless account.entitlement_source == 'stripe'
    return if account.stripe_subscription_id.present?
    return unless account.stripe_customer_id.present?

    Stripe.api_key = ENV['STRIPE_SECRET_KEY']

    subscriptions = Stripe::Subscription.list({ customer: account.stripe_customer_id, status: 'active', limit: 1 })
    subscription = subscriptions.data.first

    return unless subscription

    account.update!(stripe_subscription_id: subscription.id)
  rescue Stripe::StripeError => e
    Rails.logger.error("Stripe sync on login error: #{e.message}")
  end

  def after_sign_in_path_for(...)
    if params[:redir].present?
      return console_redirect_index_path(redir: params[:redir]) if params[:redir].starts_with?(Docuseal::CONSOLE_URL)

      return params[:redir]
    end

    super
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
  end

  def set_flash_message(key, kind, options = {})
    return if key == :alert && kind == 'already_authenticated'

    super
  end
end
