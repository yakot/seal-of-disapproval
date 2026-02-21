import { isDarkTheme } from '../lib/theme'

export default class extends HTMLElement {
  connectedCallback () {
    this.chartLabels = JSON.parse(this.dataset.labels || '[]')
    this.chartDatasets = JSON.parse(this.dataset.datasets || '[]')

    this.initChart()
  }

  disconnectedCallback () {
    if (this.chartInstance) {
      this.chartInstance.destroy()
      this.chartInstance = null
    }
  }

  async initChart () {
    const { default: Chart } = await import(/* webpackChunkName: "chartjs" */ 'chart.js/auto')
    const darkTheme = isDarkTheme()
    const axisColor = darkTheme ? '#94a3b8' : '#64748b'
    const gridColor = darkTheme ? 'rgba(148, 163, 184, 0.2)' : 'rgba(100, 116, 139, 0.2)'

    const canvas = this.querySelector('canvas')

    const ctx = canvas.getContext('2d')

    this.chartInstance = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: this.chartLabels,
        datasets: this.chartDatasets
      },
      options: {
        responsive: true,
        maintainAspectRatio: true,
        animation: false,
        scales: {
          y: {
            beginAtZero: true,
            grace: '20%',
            grid: {
              color: gridColor
            },
            ticks: {
              precision: 0,
              color: axisColor
            }
          },
          x: {
            grid: {
              color: gridColor
            },
            ticks: {
              color: axisColor
            }
          }
        },
        plugins: {
          legend: {
            display: false
          }
        }
      }
    })
  }
}
