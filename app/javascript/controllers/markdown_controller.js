import { Controller } from "@hotwired/stimulus"
import { marked } from "marked";

export default class extends Controller {
  static targets = ["markdown"];

  markdownTargetConnected(markdown) {
    markdown.innerHTML = marked.parse(markdown.innerHTML)
  }
}
