import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "categorySelect", "otherField"];
  static values = {
    businessType: { default: "", type: String }
  }

  connect() {
    const isWithinOptions = new Array(...this.categorySelectTarget.options).find(opt => opt.value === this.businessTypeValue);

    if (isWithinOptions || this.businessTypeValue.trim() === "") {
      this.otherFieldTarget.classList.add("hidden")
    } else {
      this.categorySelectTarget.value = "Other";
      this.otherFieldTarget.classList.remove("hidden")
    }
  }

  toggleOtherField() {
    if (this.categorySelectTarget.value === "Other") {
      this.otherFieldTarget.classList.remove("hidden")
    } else {
      this.otherFieldTarget.classList.add("hidden")
    }
  }

  processBeforeSubmission(e) {
    if (this.categorySelectTarget.value === "Other") {
      this.categorySelectTarget.remove();
    } else {
      this.otherFieldTarget.remove();
    }

    e.currentTarget.requestSubmit();
  }
}
