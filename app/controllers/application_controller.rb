# frozen_string_literal: true

class ApplicationController < ActionController::Base
  BROWSER_LOCALE_REGEXP = /\A\w{2}(?:-\w{2})?/

  include ActiveStorage::SetCurrent
  include Pagy::Method

  check_authorization unless: :devise_controller?

  around_action :with_locale
  before_action :sign_in_for_demo, if: -> { Docuseal.demo? }
  before_action :maybe_redirect_to_setup, unless: :signed_in?
  before_action :authenticate_user!, unless: :devise_controller?

  before_action :set_csp, if: -> { request.get? && !request.headers['HTTP_X_TURBO'] }

  helper_method :button_title,
                :current_account,
                :true_ability,
                :form_link_host,
                :svg_icon,
                :product_url,
                :current_theme_name,
                :current_theme_color,
                :current_theme_scope

  impersonates :user, with: ->(uuid) { User.find_by(uuid:) }

  rescue_from Pagy::RangeError do
    redirect_to request.path
  end

  rescue_from RateLimit::LimitApproached do |e|
    Rollbar.error(e) if defined?(Rollbar)

    redirect_to request.referer, alert: 'Too many requests', status: :too_many_requests
  end

  if Rails.env.production? || Rails.env.test?
    rescue_from CanCan::AccessDenied do |e|
      Rollbar.warning(e) if defined?(Rollbar)

      redirect_to root_path, alert: e.message
    end
  end

  def default_url_options
    if request.domain == 'docuseal.com'
      return { host: 'docuseal.com', protocol: ENV['FORCE_SSL'].present? ? 'https' : 'http' }
    end

    Docuseal.default_url_options
  end

  def impersonate_user(user)
    raise ArgumentError unless user
    raise Pretender::Error unless true_user

    @impersonated_user = user

    request.session[:impersonated_user_id] = user.uuid
  end

  def pagy_auto(collection, **keyword_args)
    if current_ability.can?(:manage, :countless)
      pagy(:countless, collection, **keyword_args)
    else
      pagy(collection, **keyword_args)
    end
  end

  private

  def with_locale(&)
    return yield unless current_account

    locale   = params[:lang].presence if Rails.env.development?
    locale ||= current_account.locale

    I18n.with_locale(locale, &)
  end

  def with_browser_locale(&)
    return yield if I18n.locale != :'en-US' && I18n.locale != :en

    locale   = params[:lang].presence
    locale ||= request.env['HTTP_ACCEPT_LANGUAGE'].to_s[BROWSER_LOCALE_REGEXP].to_s

    locale =
      if locale.starts_with?('en-') && locale != 'en-US'
        'en-GB'
      else
        locale.split('-').first.presence || 'en-GB'
      end

    locale = 'en-GB' unless I18n.locale_available?(locale)

    I18n.with_locale(locale, &)
  end

  def sign_in_for_demo
    sign_in(User.active.order('random()').take) unless signed_in?
  end

  def current_account
    current_user&.account
  end

  def true_ability
    @true_ability ||= Ability.new(true_user)
  end

  def maybe_redirect_to_setup
    return if User.exists?

    if Docuseal.multitenant?
      redirect_to new_registration_path
    else
      redirect_to setup_index_path
    end
  end

  def button_title(title: I18n.t('submit'), disabled_with: I18n.t('submitting'), title_class: '', icon: nil,
                   icon_disabled: nil)
    render_to_string(partial: 'shared/button_title',
                     locals: { title:, disabled_with:, title_class:, icon:, icon_disabled: })
  end

  def svg_icon(icon_name, class: '')
    render_to_string(partial: "icons/#{icon_name}", locals: { class: })
  end

  def form_link_host
    Docuseal.default_url_options[:host]
  end

  def current_theme_scope
    theme_account&.uuid || 'public'
  end

  def current_theme_name
    theme_value = theme_account_config&.value

    theme_value == 'dark' ? 'docuseal_dark' : 'docuseal'
  end

  def current_theme_color
    current_theme_name == 'docuseal_dark' ? '#0f172a' : '#faf7f5'
  end

  def maybe_redirect_com
    return if request.domain != 'docuseal.co'

    redirect_to request.url.gsub('.co/', '.com/'), allow_other_host: true, status: :moved_permanently
  end

  def set_csp
    request.content_security_policy = current_content_security_policy.tap do |policy|
      policy.default_src :self
      policy.script_src :self, 'https://widget.intercom.io', 'https://js.intercomcdn.com',
                         'https://www.googletagmanager.com', 'https://www.google-analytics.com',
                         'https://googleads.g.doubleclick.net',
                         'https://connect.facebook.net',
                         'https://static.ads-twitter.com',
                         'https://cdp.customer.io',
                         'https://us-assets.i.posthog.com'
      policy.style_src :self, :unsafe_inline
      policy.img_src :self, :https, :http, :blob, :data
      policy.font_src :self, :https, :http, :blob, :data
      policy.manifest_src :self
      policy.media_src :self
      policy.frame_src :self, 'https://kalendar.work', 'https://intercom-sheets.com',
                        'https://td.doubleclick.net', 'https://www.facebook.com'
      policy.worker_src :self, :blob
      policy.connect_src :self, 'https://api-iam.intercom.io', 'wss://nexus-websocket-a.intercom.io',
                          'https://www.google-analytics.com', 'https://analytics.google.com',
                          'https://region1.google-analytics.com',
                          'https://www.google.com', 'https://googleads.g.doubleclick.net',
                          'https://www.facebook.com', 'https://connect.facebook.net',
                          'https://analytics.twitter.com',
                          'https://cdp.customer.io', 'https://*.customer.io',
                          'https://us.i.posthog.com', 'https://us-assets.i.posthog.com'

      policy.directives['connect-src'] << 'ws:' if Rails.env.development?
    end
  end

  def product_url
    "#{request.protocol}#{request.host_with_port}"
  end

  def theme_account
    return current_account if current_account
    return @submitter.account if defined?(@submitter) && @submitter&.account
    return @template.account if defined?(@template) && @template&.account
    return @submission.account if defined?(@submission) && @submission&.account

    nil
  end

  def theme_account_config
    account = theme_account

    return nil unless account

    account.account_configs.find_by(key: AccountConfig::THEME_KEY)
  end
end
