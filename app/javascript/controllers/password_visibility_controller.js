import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input" ]

  toggle(event) {
    const reveal = this.inputTarget.type === "password"
    this.inputTarget.type = reveal ? "text" : "password"
    event.currentTarget.setAttribute("aria-pressed", reveal)
    event.currentTarget.setAttribute("aria-label", reveal ? "Ocultar senha" : "Mostrar senha")
  }
}
