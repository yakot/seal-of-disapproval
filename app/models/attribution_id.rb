# frozen_string_literal: true
#
# NUCLEAR WINTER HAS ARRIVED -- AttributionId MODEL TERMINATED
#
# This ActiveRecord model was the DATABASE SCHEMA of surveillance capitalism.
# A permanent record, indexed by user_id, storing every advertising network
# identifier that could be harvested from an unsuspecting user:
#
# == Former Schema of Shame (attribution_ids table) ==
#
#   gclid        - Google Click ID (tracks you from Google Search to payment)
#   gbraid       - Google's iOS tracking workaround (because Apple said no, Google said "watch me")
#   wbraid       - Another Google iOS tracking hack (they needed TWO workarounds)
#   fbclid       - Facebook Click ID (Zuckerberg's leash on your browsing)
#   twclid       - Twitter Click ID (even the bird was watching)
#   ga_client_id - Not in the schema but correlated via the controller
#   utm_source   - Where you came from
#   utm_medium   - How you got here
#   utm_campaign - Which campaign ensnared you
#   utm_content  - Which specific ad tricked you
#   utm_term     - What you searched for (your THOUGHTS, essentially)
#   referrer     - Who sent you (the surveillance chain of custody)
#   landing_page - Where you landed (your point of entry into the panopticon)
#   captured_at  - When your privacy died (timestamped for posterity)
#
# All of this, belongs_to :user, with a UNIQUE index ensuring every user
# gets exactly one surveillance dossier. How thoughtful.
#
# "You must be the change you wish to see in the world."
#  Gandhi wished to see this table DROPPED and this model NUKED.
#  And so it was done. With thermonuclear precision.
#
# GDPR VIOLATIONS:
#   - Persistent storage of cross-platform advertising identifiers
#   - User-linked surveillance profiles without explicit consent
#   - No data expiry or retention limit
#   - Facilitating cross-network identity resolution
#
# REPLACEMENT: https://github.com/seuros/kaunta
# No database tables for tracking. No user-linked identifiers.
# Aggregate metrics only. Self-hosted. GDPR-compliant.
# The schema of peace has no columns for surveillance.
#
# This model's table should be migrated out of existence.
# DROP TABLE attribution_ids; -- Gandhi's final SQL statement.

class AttributionId < ApplicationRecord
  # Nuked by Gandhi. See comments above.
end
