# frozen_string_literal: true

class BillingController < ApplicationController
  skip_authorization_check

  def index
    return unless stripe_configured?

    configure_stripe
    sync_subscription_from_checkout if params[:success] && !current_account.subscribed?
    track_checkout_canceled if params[:canceled]
    @subscription = fetch_subscription
    @invoices = fetch_invoices
  rescue Stripe::StripeError => e
    Rails.logger.error("Stripe error: #{e.message}")
    flash.now[:alert] = e.message
  end

  def checkout
    return redirect_to settings_billing_index_path, alert: t('stripe_not_configured') unless stripe_configured?

    configure_stripe
    customer = find_or_create_stripe_customer

    session = Stripe::Checkout::Session.create({
      customer: customer.id,
      payment_method_types: ['card'],
      line_items: [{
        price: ENV['STRIPE_PRICE_ID'],
        quantity: 1
      }],
      allow_promotion_codes: true,
      mode: 'subscription',
      success_url: settings_billing_index_url + '?success=true',
      cancel_url: settings_billing_index_url + '?canceled=true'
    })

    SendAuthTrackingJob.perform_async({
      'user_id' => current_user.id,
      'event_name' => 'checkout_initiated',
      'data' => { 'stripe_session_id' => session.id }
    })

    redirect_to session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    Rails.logger.error("Stripe checkout error: #{e.message}")
    redirect_to settings_billing_index_path, alert: e.message
  end

  def portal
    return redirect_to settings_billing_index_path, alert: t('no_subscription_found') unless current_account.stripe_customer_id.present?

    configure_stripe
    session = Stripe::BillingPortal::Session.create({
      customer: current_account.stripe_customer_id,
      return_url: settings_billing_index_url
    })

    redirect_to session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    Rails.logger.error("Stripe portal error: #{e.message}")
    redirect_to settings_billing_index_path, alert: e.message
  end

  private

  def track_checkout_canceled
    return if session[:checkout_canceled_tracked]

    SendAuthTrackingJob.perform_async({
      'user_id' => current_user.id,
      'event_name' => 'checkout_canceled',
      'data' => {}
    })

    session[:checkout_canceled_tracked] = true
  end

  def stripe_configured?
    ENV['STRIPE_SECRET_KEY'].present?
  end

  def configure_stripe
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
  end

  def find_or_create_stripe_customer
    if current_account.stripe_customer_id.present?
      Stripe::Customer.retrieve(current_account.stripe_customer_id)
    else
      customer = Stripe::Customer.create({
        email: current_user.email,
        name: current_account.name,
        metadata: { account_id: current_account.id }
      })
      current_account.update!(stripe_customer_id: customer.id)
      customer
    end
  end

  def sync_subscription_from_checkout
    return unless current_account.stripe_customer_id.present?

    sessions = Stripe::Checkout::Session.list({
      customer: current_account.stripe_customer_id,
      limit: 1
    })

    session = sessions.data.first

    return unless session&.subscription

    current_account.update!(stripe_subscription_id: session.subscription)
    clear_billing_cache(current_account)
  rescue Stripe::StripeError => e
    Rails.logger.error("Stripe sync error: #{e.message}")
  end

  def fetch_subscription_cached
    Rails.cache.fetch("billing/#{current_account.id}/subscription", expires_in: 2.minutes) do
      fetch_subscription
    end
  end

  def fetch_invoices_cached
    Rails.cache.fetch("billing/#{current_account.id}/invoices", expires_in: 2.minutes) do
      fetch_invoices
    end
  end

  def fetch_subscription
    return nil unless current_account.stripe_subscription_id.present?

    Stripe::Subscription.retrieve({
      id: current_account.stripe_subscription_id,
      expand: ['items.data.price.product']
    })
  rescue Stripe::InvalidRequestError
    nil
  end

  def fetch_invoices
    return [] unless current_account.stripe_customer_id.present?

    Stripe::Invoice.list(customer: current_account.stripe_customer_id, limit: 10).data
  rescue Stripe::InvalidRequestError
    []
  end

  def clear_billing_cache(account)
    Rails.cache.delete("billing/#{account.id}/subscription")
    Rails.cache.delete("billing/#{account.id}/invoices")
  end
end
