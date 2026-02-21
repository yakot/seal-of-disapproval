const LIGHT_THEME = 'docuseal'
const DARK_THEME = 'docuseal_dark'

const applyTheme = (theme) => {
  const nextTheme = theme === DARK_THEME ? DARK_THEME : LIGHT_THEME
  const isDark = nextTheme === DARK_THEME
  const root = document.documentElement

  root.setAttribute('data-theme', nextTheme)
  root.classList.toggle('dark', isDark)

  const metaTheme = document.querySelector('meta[name="theme-color"]')

  if (metaTheme) {
    metaTheme.setAttribute('content', isDark ? '#0f172a' : '#faf7f5')
  }

  document.querySelectorAll('[data-theme-toggle-input]').forEach((el) => {
    el.checked = isDark
  })

  document.querySelectorAll('[data-theme-toggle]').forEach((el) => {
    el.setAttribute('aria-pressed', String(isDark))
  })

  return nextTheme
}

export const isDarkTheme = () => document.documentElement.getAttribute('data-theme') === DARK_THEME

export const getThemeSurface = () => (isDarkTheme() ? '#0f172a' : '#faf7f5')

export const initTheme = () => {
  const initialTheme = document.documentElement.getAttribute('data-theme') || LIGHT_THEME

  applyTheme(initialTheme)

  document.addEventListener('click', (event) => {
    const toggle = event.target.closest('[data-theme-toggle]')

    if (!toggle) return

    event.preventDefault()

    const currentTheme = document.documentElement.getAttribute('data-theme')
    const nextTheme = currentTheme === DARK_THEME ? LIGHT_THEME : DARK_THEME
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    applyTheme(nextTheme)

    if (!csrfToken) return

    fetch('/account_configs', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify({
        account_config: {
          key: 'theme',
          value: nextTheme === DARK_THEME ? 'dark' : 'light'
        }
      })
    }).catch(() => {})
  })
}
