import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["loadingIndicator", "section"];

  loadingIndicatorTargetConnected(loadingIndicator) {
    loadingIndicator.classList.add("hidden");
  }

  showLoadingIndicator() {
    this.loadingIndicatorTarget.classList.remove("hidden");
    this.sectionTarget.classList.add("hidden");
  }

  hideLoadingIndicator() {
    this.loadingIndicatorTarget.classList.add("hidden");
    this.sectionTarget.classList.remove("hidden");
  }
}
