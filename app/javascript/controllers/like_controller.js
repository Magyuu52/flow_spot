import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String, liked: Boolean, count: Number, signedIn: Boolean }
  static targets = ["icon", "count", "buttonText"]

  likedValueChanged() {
    this.iconTargets.forEach(el => {
      el.classList.toggle("not-liked", !this.likedValue)
    })
    this.buttonTextTargets.forEach(el => {
      el.textContent = this.likedValue ? "いいね済み" : "いいねする"
      el.classList.toggle("btn-1", this.likedValue)
      el.classList.toggle("btn-2", !this.likedValue)
    })
  }

  countValueChanged() {
    this.countTargets.forEach(el => {
      el.textContent = this.countValue
    })
  }

  async toggle(event) {
    event.preventDefault()

    if (!this.signedInValue) {
      window.location.href = "/login"
      return
    }

    const method = this.likedValue ? "DELETE" : "POST"
    const response = await fetch(this.urlValue, {
      method,
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Accept": "application/json"
      }
    })

    if (!response.ok) return

    const data = await response.json()
    this.likedValue = data.liked
    this.countValue = data.likes_count
  }
}
