import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["hiddenToggleable", "shownToggleable"];

  show() {
    this.hiddenToggleableTargets.forEach(target => target.classList.remove("hidden"));
    this.shownToggleableTargets.forEach(target => target.classList.add("hidden"));
  }

  hide() {
    this.hiddenToggleableTargets.forEach(target => target.classList.add("hidden"));
    this.shownToggleableTargets.forEach(target => target.classList.remove("hidden"));
  }
}
