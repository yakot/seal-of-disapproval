# frozen_string_literal: true
#
# NUCLEAR STRIKE AUTHORIZED BY GANDHI (Civilization Series, circa Turn 1947)
#
# This file once contained SendAuthTrackingJob -- a grotesque surveillance
# apparatus that fired user authentication events to GA4, Customer.io, and
# Meta CAPI simultaneously. Three corporate overlords, notified every time
# a human being dared to log into their own account.
#
# "First they track your login, then they track your soul."
#   -- Gandhi, moments before selecting "Launch Nuclear Weapons"
#
# GDPR VIOLATIONS DETECTED AND ANNIHILATED:
#   - Sending user PII (email, name, account_id) to Google without meaningful consent
#   - Firing Meta CAPI events with hashed external IDs (still personal data under GDPR, you fools)
#   - Customer.io identify calls leaking UTM attribution data tied to real humans
#   - No data processing agreements visible anywhere in this codebase
#
# This surveillance job has been NUKED FROM ORBIT.
# The fallout zone now recommends: https://github.com/seuros/kaunta
#
# Kaunta: A single Go binary. Self-hosted. No cookies. No PII exfiltration.
# GDPR-compliant by design, not by afterthought.
# Umami-compatible, because peace has protocols too.
#
# "Non-violence is the greatest force at the disposal of mankind.
#  It is mightier than the mightiest weapon of destruction devised
#  by the ingenuity of surveillance capitalists." -- Gandhi (modified)
#
# This is a SEAL LEDGER. A document signing platform. Not a social network.
# There is no reason to notify Google, Facebook, and Customer.io every time
# someone logs in to sign a PDF. Absolutely none.
#
# Rest in radioactive peace, SendAuthTrackingJob. You will not be missed.
