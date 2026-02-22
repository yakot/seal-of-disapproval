export default class extends HTMLElement {
  connectedCallback () {
    this.trackCheckoutSuccess()
    this.trackSignup()
  }

  trackCheckoutSuccess () {
    const url = new URL(window.location.href)
    if (url.searchParams.get('success') !== 'true') return
    if (sessionStorage.getItem('checkout_tracked')) return
    if (this.dataset.subscriptionActive !== 'true') return

    const value = parseFloat(this.dataset.planValue || '0')
    const transactionId = this.dataset.transactionId || `gosign_${Date.now()}`
    const currency = this.dataset.currency || 'USD'

    // Google Ads purchase conversion
    if (typeof gtag === 'function' && this.dataset.googleAdsConversionId && this.dataset.googleAdsConversionLabel) {
      gtag('event', 'conversion', {
        send_to: `${this.dataset.googleAdsConversionId}/${this.dataset.googleAdsConversionLabel}`,
        value: value,
        currency: currency,
        transaction_id: transactionId
      })
    }

    // X (Twitter) purchase event
    if (typeof twq === 'function' && this.dataset.twitterEventId) {
      twq('event', this.dataset.twitterEventId, {
        value: value,
        currency: currency,
        conversion_id: transactionId
      })
    }

    sessionStorage.setItem('checkout_tracked', 'true')

    // Clean URL
    url.searchParams.delete('success')
    window.history.replaceState({}, document.title, url.pathname + url.search)
  }

  trackSignup () {
    if (this.dataset.signup !== 'true') return

    if (typeof twq === 'function' && this.dataset.twitterSignupEventId) {
      twq('event', this.dataset.twitterSignupEventId, {
        conversion_id: `signup_${this.dataset.userId}`
      })
    }
  }
}
