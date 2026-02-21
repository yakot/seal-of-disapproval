export default class extends HTMLElement {
  connectedCallback() {
    this.selectAllCheckbox = document.getElementById('select-all-submissions')
    this.submissionCheckboxes = document.querySelectorAll('.submission-checkbox')
    this.exportButton = document.getElementById('export-button')
    this.exportCount = document.getElementById('export-count')

    if (this.selectAllCheckbox) {
      this.selectAllCheckbox.addEventListener('change', (e) => {
        this.toggleAllCheckboxes(e.target.checked)
      })
    }

    this.submissionCheckboxes.forEach((checkbox) => {
      checkbox.addEventListener('change', () => {
        this.updateExportButton()
        this.updateSelectAllState()
      })
    })

    // Initial state
    this.updateExportButton()
  }

  toggleAllCheckboxes(checked) {
    this.submissionCheckboxes.forEach((checkbox) => {
      checkbox.checked = checked
    })
    this.updateExportButton()
  }

  updateSelectAllState() {
    if (!this.selectAllCheckbox) return

    const checkedCount = this.getCheckedCheckboxes().length
    const totalCount = this.submissionCheckboxes.length

    if (checkedCount === 0) {
      this.selectAllCheckbox.checked = false
      this.selectAllCheckbox.indeterminate = false
    } else if (checkedCount === totalCount) {
      this.selectAllCheckbox.checked = true
      this.selectAllCheckbox.indeterminate = false
    } else {
      this.selectAllCheckbox.checked = false
      this.selectAllCheckbox.indeterminate = true
    }
  }

  getCheckedCheckboxes() {
    return Array.from(this.submissionCheckboxes).filter(cb => cb.checked)
  }

  updateExportButton() {
    const checkedCheckboxes = this.getCheckedCheckboxes()
    const count = checkedCheckboxes.length

    if (this.exportCount) {
      if (count > 0) {
        this.exportCount.textContent = count
        this.exportCount.classList.remove('hidden')
      } else {
        this.exportCount.classList.add('hidden')
      }
    }

    if (this.exportButton) {
      // Update the export link with selected submission IDs
      const submissionIds = checkedCheckboxes.map(cb => cb.dataset.submissionId).join(',')
      const currentUrl = new URL(this.exportButton.href)

      if (submissionIds) {
        currentUrl.searchParams.set('submission_ids', submissionIds)
      } else {
        currentUrl.searchParams.delete('submission_ids')
      }

      this.exportButton.href = currentUrl.toString()
    }
  }
}
