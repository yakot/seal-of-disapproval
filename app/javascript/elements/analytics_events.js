export default class extends HTMLElement {
  connectedCallback () {
    this.trackCheckoutSuccess()
  }

  trackCheckoutSuccess () {
    const url = new URL(window.location.href)
    if (url.searchParams.get('success') !== 'true') return
    if (sessionStorage.getItem('checkout_tracked')) return
    if (this.dataset.subscriptionActive !== 'true') return

    const value = parseFloat(this.dataset.planValue || '0')
    const transactionId = this.dataset.transactionId || `gosign_${Date.now()}`
    const currency = this.dataset.currency || 'USD'

    // X (Twitter) purchase event — only client-side tracking needed (no server API)
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
}
