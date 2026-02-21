export default class extends HTMLElement {
  connectedCallback () {
    this.setActiveLink()

    this.onBeforeCache = () => {
      this.querySelectorAll('a').forEach((link) => link.classList.remove('bg-base-300'))
    }

    document.addEventListener('turbo:before-cache', this.onBeforeCache)
  }

  disconnectedCallback () {
    document.removeEventListener('turbo:before-cache', this.onBeforeCache)
  }

  setActiveLink () {
    let activeLink = null

    this.querySelectorAll('a').forEach((link) => {
      link.classList.remove('bg-base-300')

      if (document.location.pathname.startsWith(link.pathname) && !link.getAttribute('href').startsWith('http') && link.dataset.turbo !== 'false') {
        if (!activeLink || link.pathname.length > activeLink.pathname.length) {
          activeLink = link
        }
      }
    })

    if (activeLink) {
      activeLink.classList.add('bg-base-300')
    }
  }
}
