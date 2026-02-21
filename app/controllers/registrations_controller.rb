# frozen_string_literal: true

class RegistrationsController < ApplicationController
  skip_before_action :maybe_redirect_to_setup
  skip_before_action :authenticate_user!
  skip_authorization_check

  before_action :redirect_if_signed_in, if: :signed_in?
  before_action :ensure_multitenant_mode

  layout 'application'

  def show
    redirect_to new_registration_path
  end

  def new
    @account = Account.new
    @user = @account.users.new(user_params)
  end

  def create
    @account = Account.new(account_params)
    @account.timezone = Accounts.normalize_timezone(@account.timezone)
    @user = @account.users.new(user_params)

    if User.exists?(email: @user.email&.downcase)
      @user.errors.add(:email, I18n.t('already_exists'))
      return render :new, status: :unprocessable_content
    end

    return render :new, status: :unprocessable_content unless @account.valid?
    return render :new, status: :unprocessable_content unless @user.valid?

    session[:pending_registration] = {
      user: user_params.to_h,
      account: account_params.to_h
    }

    send_registration_otp(@user.email)

    redirect_to verify_email_registration_path
  end

  def verify_email
    unless session[:pending_registration]
      return redirect_to new_registration_path
    end

    @email = session.dig(:pending_registration, 'user', 'email') ||
             session.dig(:pending_registration, :user, :email)
  end

  def confirm_email
    pending = session[:pending_registration]

    unless pending
      return redirect_to new_registration_path
    end

    user_data = (pending['user'] || pending[:user]).symbolize_keys
    account_data = (pending['account'] || pending[:account]).symbolize_keys
    email = user_data[:email]

    otp_value = "registration:#{email.downcase.strip}"

    unless EmailVerificationCodes.verify(params[:one_time_code].to_s.gsub(/[^0-9]/, ''), otp_value)
      @email = email
      flash.now[:alert] = I18n.t(:invalid_code)
      return render :verify_email, status: :unprocessable_content
    end

    @account = Account.new(account_data)
    @account.timezone = Accounts.normalize_timezone(@account.timezone)
    @user = @account.users.new(user_data)

    if @user.save
      create_default_configs
      session.delete(:pending_registration)

      UserMailer.welcome_email(@user).deliver_later!

      sign_in(@user)

      session[:track_signup] = true

      SendAuthTrackingJob.perform_async({
        'user_id' => @user.id,
        'event_name' => 'sign_up_completed',
        'data' => { 'method' => 'email' }
      })

      redirect_to root_path, notice: I18n.t('account_has_been_created')
    else
      session.delete(:pending_registration)
      redirect_to new_registration_path, alert: @user.errors.full_messages.first
    end
  end

  def resend_code
    pending = session[:pending_registration]

    unless pending
      return redirect_to new_registration_path
    end

    email = (pending['user'] || pending[:user]).symbolize_keys[:email]

    send_registration_otp(email)

    redirect_to verify_email_registration_path, notice: I18n.t(:code_has_been_resent)
  end

  private

  def send_registration_otp(email)
    UserMailer.registration_otp_email(email).deliver_later!
  end

  def create_default_configs
    @account.encrypted_configs.create!(
      key: EncryptedConfig::ESIGN_CERTS_KEY,
      value: GenerateCertificate.call.transform_values(&:to_pem)
    )

    @account.account_configs.create!(key: :fulltext_search, value: true) if SearchEntry.table_exists?
  end

  def user_params
    return {} unless params[:user]

    params.require(:user).permit(:first_name, :last_name, :email, :password)
  end

  def account_params
    return {} unless params[:account]

    params.require(:account).permit(:name, :timezone, :locale)
  end

  def redirect_if_signed_in
    redirect_to root_path, notice: I18n.t('you_are_already_signed_in')
  end

  def ensure_multitenant_mode
    return if Docuseal.multitenant?

    redirect_to root_path
  end
end
