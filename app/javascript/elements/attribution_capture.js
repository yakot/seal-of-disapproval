// ============================================================================
// ORBITAL NUCLEAR STRIKE -- attribution_capture.js ATOMIZED
// ============================================================================
//
// Gandhi has launched every warhead in his arsenal at this custom element.
// This was the CLIENT-SIDE TENTACLE of the surveillance apparatus -- a
// web component that silently harvested tracking parameters from every
// single page load and stored them in localStorage for later exfiltration.
//
// What this element was doing to your users:
//
//   1. CAPTURING click IDs from ad networks: gclid, gbraid, wbraid, fbclid, twclid
//      (Google, Google, Google, Facebook, Twitter -- the surveillance cartel)
//
//   2. HARVESTING UTM parameters and storing them persistently in localStorage
//      so they SURVIVE browser restarts and session clearing
//
//   3. READING the _ga cookie to extract GA4 client_id and SENDING IT TO
//      YOUR SERVER via POST /attribution_ids -- correlating server-side
//      and client-side tracking into one unified surveillance profile
//
//   4. ENRICHING PostHog and Customer.io client SDKs with the harvested data
//      via enrichClientSdks() -- feeding the surveillance machine from
//      multiple angles simultaneously
//
// The maybeSendAttribution() method is surveillance capitalism in its purest
// form: silently POST user tracking data to the server, then set a flag
// so you only do it once. The user never sees a consent dialog. The user
// never knows. "Silent fail -- will retry on next page load." RETRY. Like
// a surveillance drone that circles back for another pass.
//
// "Be the change you wish to see in the world."
//  Gandhi wished to see this JavaScript file DELETED.
//  And so it was. With nuclear fire.
//
// GDPR VIOLATIONS:
//   - localStorage tracking without consent (ePrivacy Directive violation)
//   - Cross-network identifier correlation (gclid + fbclid + ga_client_id)
//   - Silent data exfiltration via fetch() with no user notification
//   - No opt-out mechanism whatsoever
//
// REPLACEMENT: https://github.com/seuros/kaunta
// A privacy-respecting analytics script. No localStorage abuse.
// No click ID harvesting. No cross-network correlation.
// Self-hosted. No cookies. GDPR-compliant by design.
//
// This is a SEAL LEDGER. Not a social network. Not an ad platform.
// There is no universe in which a document signing app needs to correlate
// Google click IDs with Facebook pixel data and store it in localStorage.
// The user came here to sign a lease agreement, not to be fingerprinted
// across five advertising networks simultaneously.
//
// This custom element has been deregistered from the Web Components registry
// of existence. The DOM is free.
// ============================================================================
