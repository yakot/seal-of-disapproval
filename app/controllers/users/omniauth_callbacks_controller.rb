# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token, only: %i[google_oauth2 microsoft_graph]
    skip_authorization_check

    def google_oauth2
      handle_auth('Google')
    end

    def microsoft_graph
      handle_auth('Microsoft')
    end

    def failure
      redirect_to new_user_session_path, alert: "Authentication failed: #{failure_message}"
    end

    private

    def handle_auth(provider_name)
      auth = request.env['omniauth.auth']

      account = find_or_create_account(auth)
      new_user = User.find_by(email: auth.info.email&.downcase).nil?
      user = User.from_omniauth(auth, account:)

      UserMailer.welcome_email(user).deliver_later! if new_user && user.persisted?

      if user.persisted?
        event_name = new_user ? 'sign_up_completed' : 'login_completed'
        SendAuthTrackingJob.perform_async({
          'user_id' => user.id,
          'event_name' => event_name,
          'data' => { 'method' => provider_name.downcase }
        })

        if user.otp_required_for_login?
          session[:otp_user_id] = user.id
          redirect_to new_user_session_path, notice: I18n.t('enter_your_2fa_code')
        else
          sign_in_and_redirect user, event: :authentication
          set_flash_message(:notice, :success, kind: provider_name) if is_navigational_format?
        end
      else
        session["devise.#{auth.provider}_data"] = auth.except(:extra)
        redirect_to new_user_session_path, alert: user.errors.full_messages.join("\n")
      end
    end

    def find_or_create_account(auth)
      email = auth.info.email&.downcase

      existing_user = User.find_by(email:)
      return existing_user.account if existing_user

      if Docuseal.multitenant?
        state_params = parse_state_param
        domain = email&.split('@')&.last

        Account.create!(
          name: domain&.split('.')&.first&.titleize || 'My Company',
          timezone: Accounts.normalize_timezone(state_params[:timezone] || 'UTC'),
          locale: I18n.locale
        ).tap do |account|
          account.encrypted_configs.create!(
            key: EncryptedConfig::ESIGN_CERTS_KEY,
            value: GenerateCertificate.call.transform_values(&:to_pem)
          )
        end
      else
        Account.first
      end
    end

    def parse_state_param
      return {} if params[:state].blank?

      Rack::Utils.parse_nested_query(params[:state]).symbolize_keys
    rescue StandardError
      {}
    end
  end
end
