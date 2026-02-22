export default class extends HTMLElement {
  static CLICK_ID_PARAMS = ['gclid', 'gbraid', 'wbraid', 'fbclid', 'twclid']
  static UTM_PARAMS = ['utm_source', 'utm_medium', 'utm_campaign', 'utm_content', 'utm_term']
  static STORAGE_KEY = 'attr_click_ids'
  static SENT_KEY = 'attr_sent'

  connectedCallback () {
    this.captureParams()
    this.maybeSendAttribution()
  }

  captureParams () {
    const url = new URL(window.location.href)
    const stored = JSON.parse(localStorage.getItem(this.constructor.STORAGE_KEY) || '{}')
    const isFirstVisit = Object.keys(stored).length === 0
    let updated = false

    for (const param of this.constructor.CLICK_ID_PARAMS) {
      const value = url.searchParams.get(param)
      if (value && !stored[param]) {
        stored[param] = value
        updated = true
      }
    }

    for (const param of this.constructor.UTM_PARAMS) {
      const value = url.searchParams.get(param)
      if (value && !stored[param]) {
        stored[param] = value
        updated = true
      }
    }

    if (isFirstVisit) {
      const referrer = url.searchParams.get('referrer') ||
        (document.referrer ? new URL(document.referrer).hostname : null)
      if (referrer) {
        stored.referrer = referrer
        updated = true
      }

      const landingPage = url.searchParams.get('landing_page') ||
        window.location.pathname
      stored.landing_page = landingPage
      updated = true
    }

    if (updated) {
      localStorage.setItem(this.constructor.STORAGE_KEY, JSON.stringify(stored))
    }
  }

  maybeSendAttribution () {
    if (this.dataset.signedIn !== 'true') return
    if (localStorage.getItem(this.constructor.SENT_KEY)) return

    const stored = JSON.parse(localStorage.getItem(this.constructor.STORAGE_KEY) || '{}')
    if (Object.keys(stored).length === 0) return

    // Capture GA4 client_id from the _ga cookie
    const gaCookie = document.cookie.split('; ').find(c => c.startsWith('_ga='))
    if (gaCookie) {
      const parts = gaCookie.split('.')
      if (parts.length >= 4) {
        stored.ga_client_id = parts.slice(2).join('.')
      }
    }

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    fetch('/attribution_ids', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify(stored)
    }).then(() => {
      localStorage.setItem(this.constructor.SENT_KEY, 'true')
      this.enrichClientSdks(stored)
    }).catch(() => {
      // Silent fail — will retry on next page load
    })
  }

  enrichClientSdks (data) {
    const utmProps = {}
    for (const param of this.constructor.UTM_PARAMS) {
      if (data[param]) utmProps[param] = data[param]
    }
    if (data.referrer) utmProps.referrer = data.referrer
    if (data.landing_page) utmProps.landing_page = data.landing_page

    if (Object.keys(utmProps).length === 0) return

    if (window.posthog) {
      window.posthog.setPersonProperties(utmProps)
    }

    if (window.cioanalytics) {
      window.cioanalytics.identify({ traits: utmProps })
    }
  }
}
