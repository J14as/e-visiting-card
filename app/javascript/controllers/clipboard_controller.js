import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "button", "feedback"]
  static values = {
    text: String,
    successDuration: { type: Number, default: 2000 }
  }

  copy(event) {
    if (event) event.preventDefault()

    const textToCopy = this.hasSourceTarget
      ? (this.sourceTarget.value || this.sourceTarget.textContent || "").trim()
      : this.textValue

    if (!textToCopy) return

    navigator.clipboard.writeText(textToCopy).then(() => {
      this.showSuccess()
    }).catch(err => {
      console.error("Clipboard copy failed: ", err)
      // Fallback
      const textarea = document.createElement("textarea")
      textarea.value = textToCopy
      document.body.appendChild(textarea)
      textarea.select()
      document.execCommand("copy")
      document.body.removeChild(textarea)
      this.showSuccess()
    })
  }

  showSuccess() {
    if (this.hasFeedbackTarget) {
      this.feedbackTarget.classList.remove("hidden")
      setTimeout(() => {
        this.feedbackTarget.classList.add("hidden")
      }, this.successDurationValue)
    }

    if (this.hasButtonTarget) {
      const originalHTML = this.buttonTarget.innerHTML
      this.buttonTarget.innerHTML = `
        <svg class="w-4 h-4 text-emerald-400 inline mr-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
        </svg>
        <span>Copied!</span>
      `
      setTimeout(() => {
        this.buttonTarget.innerHTML = originalHTML
      }, this.successDurationValue)
    }
  }
}

