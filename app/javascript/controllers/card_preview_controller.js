import { Controller } from "@hotwired/stimulus"

export default stimulusController()

function stimulusController() {
  return class extends Controller {
    static targets = [
      // Inputs
      "fullNameInput",
      "designationInput",
      "companyInput",
      "bioInput",
      "phoneInput",
      "emailInput",
      "websiteInput",
      "linkedinInput",
      "githubInput",
      "instagramInput",
      "portfolioInput",
      "styleInput",
      "colorInput",
      "slugInput",

      // Preview displays
      "previewCardContainer",
      "previewFullName",
      "previewInitials",
      "previewDesignation",
      "previewCompany",
      "previewBio",
      "previewPhone",
      "previewPhoneContainer",
      "previewEmail",
      "previewEmailContainer",
      "previewWebsite",
      "previewWebsiteContainer",
      "previewLinkedin",
      "previewGithub",
      "previewInstagram",
      "previewPortfolio",
      "previewSlug",
      "previewCardFront",
      "previewCardBack",
      "flipBtnLabel"
    ]

    static values = {
      defaultInitials: String,
      activeSide: { type: String, default: "front" }
    }

    connect() {
      this.updateAll()
    }

    updateAll() {
      this.updateFullName()
      this.updateDesignation()
      this.updateCompany()
      this.updateBio()
      this.updatePhone()
      this.updateEmail()
      this.updateWebsite()
      this.updateSocials()
      this.updateSlug()
      this.updateTheme()
    }

    updateFullName() {
      if (!this.hasFullNameInputTarget) return
      const val = this.fullNameInputTarget.value.trim()
      const display = val.length > 0 ? val : "Alex Sterling"

      if (this.hasPreviewFullNameTarget) {
        this.previewFullNameTarget.textContent = display
      }

      if (this.hasPreviewInitialsTarget) {
        const parts = display.split(/\s+/).filter(Boolean)
        let inits = "VC"
        if (parts.length >= 2) {
          inits = (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
        } else if (parts.length === 1 && parts[0].length > 0) {
          inits = parts[0].slice(0, 2).toUpperCase()
        }
        this.previewInitialsTarget.textContent = inits
      }
    }

    updateDesignation() {
      if (!this.hasDesignationInputTarget || !this.hasPreviewDesignationTarget) return
      const val = this.designationInputTarget.value.trim()
      this.previewDesignationTarget.textContent = val.length > 0 ? val : "Principal Cloud Architect"
    }

    updateCompany() {
      if (!this.hasCompanyInputTarget || !this.hasPreviewCompanyTarget) return
      const val = this.companyInputTarget.value.trim()
      this.previewCompanyTarget.textContent = val.length > 0 ? val : "Nexus Systems"
    }

    updateBio() {
      if (!this.hasBioInputTarget || !this.hasPreviewBioTarget) return
      const val = this.bioInputTarget.value.trim()
      this.previewBioTarget.textContent = val.length > 0
        ? val
        : "Building high-performance distributed systems, scalable web apps, and modern developer infrastructure."
    }

    updatePhone() {
      if (!this.hasPhoneInputTarget || !this.hasPreviewPhoneTarget) return
      const val = this.phoneInputTarget.value.trim()
      if (val.length > 0) {
        this.previewPhoneTarget.textContent = val
        if (this.hasPreviewPhoneContainerTarget) this.previewPhoneContainerTarget.classList.remove("hidden")
      } else {
        if (this.hasPreviewPhoneContainerTarget) this.previewPhoneContainerTarget.classList.add("hidden")
      }
    }

    updateEmail() {
      if (!this.hasEmailInputTarget || !this.hasPreviewEmailTarget) return
      const val = this.emailInputTarget.value.trim()
      if (val.length > 0) {
        this.previewEmailTarget.textContent = val
        if (this.hasPreviewEmailContainerTarget) this.previewEmailContainerTarget.classList.remove("hidden")
      } else {
        if (this.hasPreviewEmailContainerTarget) this.previewEmailContainerTarget.classList.add("hidden")
      }
    }

    updateWebsite() {
      if (!this.hasWebsiteInputTarget || !this.hasPreviewWebsiteTarget) return
      const val = this.websiteInputTarget.value.trim()
      if (val.length > 0) {
        const clean = val.replace(/^https?:\/\/(www\.)?/, "")
        this.previewWebsiteTarget.textContent = clean
        if (this.hasPreviewWebsiteContainerTarget) this.previewWebsiteContainerTarget.classList.remove("hidden")
      } else {
        if (this.hasPreviewWebsiteContainerTarget) this.previewWebsiteContainerTarget.classList.add("hidden")
      }
    }

    updateSocials() {
      if (this.hasLinkedinInputTarget && this.hasPreviewLinkedinTarget) {
        this.toggleSocialTarget(this.linkedinInputTarget, this.previewLinkedinTarget)
      }
      if (this.hasGithubInputTarget && this.hasPreviewGithubTarget) {
        this.toggleSocialTarget(this.githubInputTarget, this.previewGithubTarget)
      }
      if (this.hasInstagramInputTarget && this.hasPreviewInstagramTarget) {
        this.toggleSocialTarget(this.instagramInputTarget, this.previewInstagramTarget)
      }
      if (this.hasWebsiteInputTarget && this.hasPreviewPortfolioTarget) {
        this.toggleSocialTarget(this.websiteInputTarget, this.previewPortfolioTarget)
      }
    }

    toggleSocialTarget(inputTarget, previewTarget) {
      if (!inputTarget || !previewTarget) return
      const val = inputTarget.value.trim()
      if (val.length > 0) {
        previewTarget.classList.remove("opacity-25", "grayscale", "pointer-events-none")
        previewTarget.classList.add("opacity-100")
      } else {
        previewTarget.classList.add("opacity-25", "grayscale", "pointer-events-none")
        previewTarget.classList.remove("opacity-100")
      }
    }

    updateSlug() {
      if (!this.hasSlugInputTarget || !this.hasPreviewSlugTarget) return
      const val = this.slugInputTarget.value.trim()
      this.previewSlugTarget.textContent = val.length > 0 ? val : "your-custom-slug"
    }

    updateTheme() {
      // Find selected style
      let selectedStyle = "modern_dark"
      const checkedStyleRadio = this.element.querySelector('input[name="visiting_card[template_style]"]:checked')
      if (checkedStyleRadio) {
        selectedStyle = checkedStyleRadio.value
      } else if (this.hasStyleInputTarget) {
        selectedStyle = this.styleInputTarget.value
      }

      // Find selected color
      let selectedColor = "indigo"
      const checkedColorRadio = this.element.querySelector('input[name="visiting_card[color_theme]"]:checked')
      if (checkedColorRadio) {
        selectedColor = checkedColorRadio.value
      } else if (this.hasColorInputTarget) {
        selectedColor = this.colorInputTarget.value
      }

      if (this.hasPreviewCardContainerTarget) {
        // Remove existing theme classes
        this.previewCardContainerTarget.setAttribute("data-theme-style", selectedStyle)
        this.previewCardContainerTarget.setAttribute("data-theme-color", selectedColor)
      }
    }

    toggleSide() {
      if (this.activeSideValue === "front") {
        this.activeSideValue = "back"
        if (this.hasPreviewCardFrontTarget) this.previewCardFrontTarget.classList.add("hidden")
        if (this.hasPreviewCardBackTarget) this.previewCardBackTarget.classList.remove("hidden")
        if (this.hasFlipBtnLabelTarget) this.flipBtnLabelTarget.textContent = "View Front Side"
      } else {
        this.activeSideValue = "front"
        if (this.hasPreviewCardFrontTarget) this.previewCardFrontTarget.classList.remove("hidden")
        if (this.hasPreviewCardBackTarget) this.previewCardBackTarget.classList.add("hidden")
        if (this.hasFlipBtnLabelTarget) this.flipBtnLabelTarget.textContent = "View Back Side (QR)"
      }
    }
  }
}
