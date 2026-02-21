# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def invitation_email(user, invited_by: nil)
    @current_account = invited_by&.account || user.account
    @user = user
    @token = @user.send(:set_reset_password_token)

    assign_message_metadata('user_invitation', @user)

    I18n.with_locale(@current_account.locale) do
      mail(to: @user.friendly_name,
           subject: I18n.t('you_are_invited_to_product_name', product_name: Docuseal.product_name))
    end
  end

  def welcome_email(user)
    @current_account = user.account
    @user = user

    assign_message_metadata('welcome_email', @user)

    mail(to: @user.friendly_name, from: 'Talha from GoSign <talha@founding.dev>', subject: 'Welcome to GoSign')
  end

  def registration_otp_email(email)
    @otp_code = EmailVerificationCodes.generate("registration:#{email.downcase.strip}")

    mail(to: email, subject: I18n.t('email_verification'))
  end
end
