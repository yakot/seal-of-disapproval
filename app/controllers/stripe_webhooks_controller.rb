# frozen_string_literal: true

class StripeWebhooksController < ApplicationController
  skip_before_action :authenticate_user!
  skip_authorization_check
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, ENV['STRIPE_WEBHOOK_SECRET']
      )
    rescue JSON::ParserError, Stripe::SignatureVerificationError => e
      Rails.logger.error("Stripe webhook error: #{e.message}")
      return head :bad_request
    end

    handle_event(event)
    head :ok
  end

  private

  def handle_event(event)
    return if ProcessedStripeEvent.already_processed?(event.id)

    case event.type
    when 'checkout.session.completed'
      handle_checkout_completed(event.data.object)
    when 'customer.subscription.created'
      handle_subscription_created(event.data.object)
    when 'customer.subscription.updated'
      handle_subscription_updated(event.data.object)
    when 'customer.subscription.deleted'
      handle_subscription_deleted(event.data.object)
    when 'invoice.paid'
      handle_invoice_paid(event.data.object)
    when 'invoice.payment_failed'
      handle_invoice_payment_failed(event.data.object)
    end

    record_processed_event(event)
  rescue ActiveRecord::RecordNotUnique
    Rails.logger.info("Stripe event #{event.id} already processed (race condition)")
  end

  def record_processed_event(event)
    invoice_id = event.data.object.try(:id) if event.type.start_with?('invoice.')

    ProcessedStripeEvent.create!(
      stripe_event_id: event.id,
      event_type: event.type,
      stripe_invoice_id: invoice_id,
      account_id: find_account_id(event.data.object),
      metadata: { processed_at: Time.current.iso8601 }
    )
  rescue ActiveRecord::RecordNotUnique
    # Already processed
  end

  def find_account_id(object)
    customer_id = object.try(:customer)
    return nil unless customer_id

    Account.find_by(stripe_customer_id: customer_id)&.id
  end

  def handle_checkout_completed(session)
    return unless session.mode == 'subscription'

    account = Account.find_by(stripe_customer_id: session.customer)
    return unless account

    account.update!(
      stripe_subscription_id: session.subscription,
      entitlement_source: 'stripe',
      entitlement_expires_at: nil,
      entitlement_reason: nil,
      granted_by_admin_id: nil
    )
    clear_billing_cache(account)
    Rails.logger.info("Subscription created for account #{account.id}: #{session.subscription}")
  end

  def handle_subscription_created(subscription)
    account = Account.find_by(stripe_customer_id: subscription.customer)
    return unless account

    account.update!(
      stripe_subscription_id: subscription.id,
      entitlement_source: 'stripe',
      entitlement_expires_at: nil,
      entitlement_reason: nil,
      granted_by_admin_id: nil
    )
    clear_billing_cache(account)
    Rails.logger.info("Subscription created for account #{account.id}: #{subscription.id}")

    SendSubscriptionTrackingJob.perform_async({
      'account_id' => account.id,
      'event_name' => 'subscription_started',
      'subscription_id' => subscription.id,
      'status' => subscription.status
    })
  end

  def handle_subscription_updated(subscription)
    account = Account.find_by(stripe_customer_id: subscription.customer)
    return unless account

    previous_attributes = subscription.respond_to?(:previous_attributes) ? subscription.previous_attributes : {}
    event_name = determine_subscription_change(subscription, previous_attributes)

    account.update!(stripe_subscription_id: subscription.id)
    clear_billing_cache(account)
    Rails.logger.info("Subscription updated for account #{account.id}: #{subscription.id}")

    return unless event_name

    SendSubscriptionTrackingJob.perform_async({
      'account_id' => account.id,
      'event_name' => event_name,
      'subscription_id' => subscription.id,
      'status' => subscription.status
    })
  end

  def handle_subscription_deleted(subscription)
    account = Account.find_by(stripe_customer_id: subscription.customer)
    return unless account

    account.update!(stripe_subscription_id: nil)
    clear_billing_cache(account)
    Rails.logger.info("Subscription deleted for account #{account.id}")

    SendSubscriptionTrackingJob.perform_async({
      'account_id' => account.id,
      'event_name' => 'subscription_cancelled',
      'subscription_id' => subscription.id,
      'status' => subscription.status
    })
  end

  def handle_invoice_paid(invoice)
    account = Account.find_by(stripe_customer_id: invoice.customer)
    return unless account

    Rails.logger.info("Invoice paid for account #{account.id}: #{invoice.id}")
    clear_billing_cache(account)

    is_first = !ProcessedStripeEvent.where(event_type: 'invoice.paid', account_id: account.id).exists?

    SendInvoicePaidTrackingJob.perform_async({
      'account_id' => account.id,
      'invoice_id' => invoice.id,
      'amount_paid' => invoice.amount_paid,
      'currency' => invoice.currency,
      'is_first_invoice' => is_first
    })
  end

  def handle_invoice_payment_failed(invoice)
    account = Account.find_by(stripe_customer_id: invoice.customer)
    return unless account

    Rails.logger.info("Invoice payment failed for account #{account.id}: #{invoice.id}")
    clear_billing_cache(account)

    SendSubscriptionTrackingJob.perform_async({
      'account_id' => account.id,
      'event_name' => 'payment_failed',
      'subscription_id' => invoice.subscription,
      'status' => 'payment_failed'
    })
  end

  def clear_billing_cache(account)
    Rails.cache.delete("billing/#{account.id}/subscription")
    Rails.cache.delete("billing/#{account.id}/invoices")
  end

  def determine_subscription_change(subscription, previous_attributes)
    if previous_attributes.respond_to?(:key?) && previous_attributes.key?('items')
      'subscription_upgraded'
    elsif subscription.cancel_at_period_end
      'subscription_downgraded'
    end
  end
end
