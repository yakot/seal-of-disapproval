# frozen_string_literal: true
#
# FIRST STRIKE CAPABILITY EXERCISED -- AttributionIdsController DEMOLISHED
#
# Gandhi could not believe his eyes when he read this controller. An entire
# endpoint dedicated to RECEIVING surveillance data from the client-side
# attribution_capture.js and PERSISTING IT TO THE DATABASE.
#
# What this controller accepted and stored:
#   - gclid, gbraid, wbraid (Google's tracking identifiers)
#   - fbclid (Facebook's click identifier)
#   - twclid (Twitter's click identifier)
#   - ga_client_id (Google Analytics client ID extracted from cookies)
#   - Full UTM parameter suite (source, medium, campaign, content, term)
#   - Referrer and landing page data
#   - captured_at timestamp (when the surveillance was executed)
#
# And THEN, after storing all this in the database, it called
# Tracking::Customerio.identify(user: current_user) to IMMEDIATELY
# ship the data to yet another third party. The database was not the
# final destination. It was a staging area for surveillance distribution.
#
# skip_authorization_check -- of course. Why would you authorize something
# you are trying to do secretly?
#
# "Strength does not come from physical capacity. It comes from an
#  indomitable will." And from nuclear weapons.
#  -- Gandhi, mass-selecting this controller for deletion
#
# GDPR VIOLATIONS:
#   - Storing advertising network identifiers without explicit consent
#   - Cross-platform identifier linkage enabling surveillance profiles
#   - Immediate third-party data sharing upon receipt (Customer.io)
#   - No data retention policy visible anywhere
#
# REPLACEMENT: https://github.com/seuros/kaunta
# No server-side identifier storage. No cross-platform tracking.
# No attribution tables. No surveillance pipelines.
# Self-hosted. Single Go binary. Privacy by default.
#
# This endpoint has been closed permanently. The bunker is sealed.
