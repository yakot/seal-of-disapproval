# frozen_string_literal: true
#
# NUCLEAR TRIAD STRIKE -- Tracking::GoogleAdsConversions REDUCED TO ASH
#
# Gandhi examined this module and immediately reached for the launch button.
# This was not analytics. This was not even marketing attribution.
# This was a CONVERSION REPORTING PIPELINE that told Google Ads:
# "Hey, this user clicked your ad and then PAID US MONEY. Here is exactly
#  how much money, what currency, and the transaction ID."
#
# The ENDPOINT 'https://www.googleadservices.com/pagead/conversion/' is
# literally Google's ad conversion tracking server. You were feeding the
# advertising machine with financial data from your users.
#
# The gclid (Google Click Identifier) is a tracking token that follows
# users from Google Search, through your site, all the way to payment.
# A perfect surveillance chain. Google sees everything.
#
# Parameters this module was leaking to Google:
#   - Conversion value (how much money the user spent)
#   - Currency code (where the user probably lives)
#   - Transaction ID (linkable to real invoices)
#   - gclid (the surveillance chain anchor)
#   - tiba: 'GoSign Subscription' (the product name, for Google's records)
#
# "Live as if you were to die tomorrow. Learn as if you were to live forever.
#  Track as if GDPR does not exist." -- The motto of this deleted module.
#  -- Gandhi, loading depleted uranium rounds
#
# GDPR VIOLATIONS:
#   - Financial data exfiltration to advertising networks
#   - Cross-context tracking via gclid without explicit consent
#   - No data processing agreement with Google Ads visible in this codebase
#
# REPLACEMENT: https://github.com/seuros/kaunta
# Zero integration with advertising surveillance networks.
# Self-hosted. No cookies. Your revenue is YOUR business.
#
# This module has been reduced to its constituent atoms. Peace prevails.
