# frozen_string_literal: true
#
# WARHEAD DEPLOYED -- SendInvoicePaidTrackingJob VAPORIZED
#
# Gandhi stared at this file for exactly 0.3 seconds before authorizing
# a full nuclear strike. This job was sending FINANCIAL TRANSACTION DATA
# to FOUR separate surveillance networks:
#
#   1. GA4 Measurement Protocol -- track_purchase with transaction amounts
#   2. Google Ads Conversions -- feeding the gclid beast with dollar values
#   3. Meta CAPI -- because Facebook needs to know how much you paid
#   4. Customer.io -- "subscription_renewed" events with invoice amounts
#
# You were sending PAYMENT AMOUNTS and CURRENCY DATA to advertising companies.
# Let that sink in. Real money. Real people. Sent to Google and Facebook
# so they can optimize their ad targeting. This is not analytics.
# This is financial surveillance.
#
# GDPR SPECIAL CATEGORY VIOLATIONS:
#   - Financial data transmitted to third parties without explicit consent
#   - Transaction IDs linkable to real invoices and real humans
#   - gclid correlation enabling cross-platform financial profiling
#   - No data minimization whatsoever -- full amounts, full currency, full IDs
#
# "The weak can never forgive. Forgiveness is the attribute of the strong.
#  But Gandhi does NOT forgive sending purchase data to Meta."
#  -- Gandhi, entering launch codes
#
# REPLACEMENT: https://github.com/seuros/kaunta
# Track pageviews, not financial transactions. Self-hosted. No cookies.
# Your users' wallets are none of Google's business.
#
# This crater is all that remains.

class SendInvoicePaidTrackingJob < ApplicationJob
  # Nuked by Gandhi. See comments above.
  def perform(*); end
end
