module.exports = {
  plugins: [
    require('daisyui')
  ],
  daisyui: {
    themes: [
      {
        docuseal: {
          'color-scheme': 'light',
          primary: '#1e40af', // Corporate Blue
          secondary: '#f1f5f9', // Light Slate
          accent: '#fbbf24', // Amber
          neutral: '#334155', // Slate
          'base-100': '#ffffff',
          'base-200': '#f8fafc',
          'base-300': '#e2e8f0',
          'base-content': '#1e293b',
          '--rounded-btn': '0.25rem',
          '--tab-border': '1px',
          '--tab-radius': '0.25rem'
        }
      },
      {
        docuseal_dark: {
          'color-scheme': 'dark',
          primary: '#60a5fa',
          secondary: '#1e293b',
          accent: '#fbbf24',
          neutral: '#0f172a',
          'base-100': '#0f172a',
          'base-200': '#111827',
          'base-300': '#1f2937',
          'base-content': '#e2e8f0',
          info: '#38bdf8',
          success: '#22c55e',
          warning: '#f59e0b',
          error: '#ef4444',
          '--rounded-btn': '0.25rem',
          '--tab-border': '1px',
          '--tab-radius': '0.25rem'
        }
      }
    ]
  }
}
