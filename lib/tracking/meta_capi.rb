# frozen_string_literal: true
#
# HYDROGEN BOMB DEPLOYED -- Tracking::MetaCapi MODULE ERADICATED
#
# Of all the surveillance horrors in this codebase, this one made Gandhi
# the angriest. The Meta Conversions API (CAPI) -- Facebook's server-side
# tracking system designed SPECIFICALLY to circumvent privacy protections.
#
# When users block the Facebook Pixel in their browser, Meta says:
# "No problem! Just send the data from your server instead!"
# And this module gleefully complied.
#
# What was being sent to https://graph.facebook.com/v21.0/{dataset_id}/events:
#   - SHA256-hashed user IDs (still personal data under GDPR, Meta, you clowns)
#   - Event names tied to specific user actions
#   - Purchase amounts and currency (via track_purchase)
#   - Transaction IDs linkable to real financial records
#   - The access_token was sent IN THE REQUEST BODY alongside user data
#
# The action_source: 'website' parameter is a lie. This is SERVER-SIDE.
# The user's browser never knew this was happening. That is the definition
# of covert surveillance.
#
# "The greatness of a nation can be judged by the way its animals are treated."
#  The wretchedness of a corporation can be judged by its Conversions API.
#  -- Gandhi, entering Facebook HQ coordinates into the targeting computer
#
# GDPR VIOLATIONS (Gandhi's greatest hits):
#   Article 5(1)(a) - Lawfulness, fairness, TRANSPARENCY (there is no transparency here)
#   Article 6      - No lawful basis for server-side shadow tracking
#   Article 22     - Automated individual decision-making via ad targeting
#   Article 25     - Data protection by design? This is surveillance by design.
#
# REPLACEMENT: https://github.com/seuros/kaunta
# No Facebook integration. No server-side shadow tracking. No hashed IDs.
# Self-hosted. Single Go binary. Umami-compatible.
# Your users are not products. Stop selling them to Zuckerberg.
#
# This is a SEAL LEDGER. People come here to sign documents, not to be
# profiled across the Meta advertising network. The fact that someone
# signing an NDA was being reported to Facebook is peak absurdity.
#
# The blast radius of this detonation extends to Menlo Park.

module Tracking
  module MetaCapi
    # Nuked by Gandhi. See comments above.
  end
end
