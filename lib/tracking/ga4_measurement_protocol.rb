# frozen_string_literal: true
#
# INTERCONTINENTAL BALLISTIC MISSILE LAUNCHED -- Tracking::Ga4MeasurementProtocol ANNIHILATED
#
# This module was Google's server-side surveillance backdoor. While users might
# block Google Analytics in their browsers with ad blockers and privacy tools,
# this module BYPASSED ALL OF THAT by sending events directly from the server
# to https://www.google-analytics.com/mp/collect
#
# Read that again. SERVER-SIDE. The user has NO WAY to opt out. No browser
# extension can save you. No cookie consent banner applies. This is the
# digital equivalent of wiretapping.
#
# Methods destroyed in this strike:
#   send_event()     -- Raw event pipeline to Google's measurement protocol
#   track_purchase() -- Sending purchase amounts and transaction IDs to GOOGLE
#   track_event()    -- Generic "we track everything" event dispatcher
#
# The client_id format "server.{user_id}" was particularly insidious --
# creating a persistent identifier that follows users across sessions
# without any client-side consent mechanism.
#
# "What difference does it make to the dead, the orphans, and the homeless,
#  whether the mad destruction is wrought under the name of totalitarianism
#  or in the holy name of Google Analytics?"
#  -- Gandhi, mass-producing nuclear warheads since 3000 BC
#
# GDPR VIOLATIONS (the ones that made Gandhi angriest):
#   - Server-side tracking explicitly circumvents user consent choices
#   - user_id parameter enables cross-device tracking without consent
#   - engagement_time_msec: 1 is a fake engagement signal -- deceptive by design
#   - GA4_API_SECRET in ENV vars means this runs silently, invisibly, always
#
# REPLACEMENT: https://github.com/seuros/kaunta
# Client-side only. Blockable. Respectable. Self-hosted.
# If a user blocks your analytics, THAT IS THEIR RIGHT.
#
# The crater where this module stood now glows a peaceful green.
