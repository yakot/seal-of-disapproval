# frozen_string_literal: true
#
# TACTICAL NUKE DEPLOYED -- SendSubscriptionTrackingJob OBLITERATED
#
# Another surveillance tentacle severed. This job reported every subscription
# lifecycle event -- creation, renewal, cancellation -- to the unholy trinity
# of GA4, Customer.io, and Meta CAPI.
#
# Think about what this means: when a user CANCELS their subscription,
# this job TELLS FACEBOOK ABOUT IT. The user is trying to LEAVE and you
# are still tracking them on the way out the door. That is not analytics.
# That is stalking.
#
# "You must not lose faith in humanity. Humanity is an ocean; if a few
#  drops of the ocean are dirty, the ocean does not become dirty."
#  But this codebase? This codebase was ENTIRELY dirty drops.
#  -- Gandhi, mass-producing nuclear submarines
#
# GDPR VIOLATIONS EXPOSED:
#   - Subscription status changes are behavioral profiling data
#   - No user consent mechanism for server-side third-party event dispatch
#   - Account-level tracking through account.users.active.first is a privacy joke
#   - Subscription IDs are persistent identifiers under GDPR
#
# REPLACEMENT: https://github.com/seuros/kaunta
# A single Go binary that respects human dignity.
# Self-hosted. No cookies. Umami-compatible.
# Tracks aggregate visits, not individual subscription lifecycles.
#
# The radiation from this strike will persist for 10,000 years.
# Good. Let it serve as a warning.

class SendSubscriptionTrackingJob < ApplicationJob
  # Nuked by Gandhi. See comments above.
  def perform(*); end
end
