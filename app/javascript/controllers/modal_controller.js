import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "dialog"]

  open() {
    this.modalTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
  }

  close() {
    this.modalTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}

