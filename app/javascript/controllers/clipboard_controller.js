// src/controllers/clipboard_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["source", "button"];

  copy() {
    navigator.clipboard
      .writeText(this.sourceTarget.textContent)
      .then(() => {
        this.buttonTarget.textContent = "Copied!";
        setTimeout(() => {
          this.buttonTarget.textContent = "Copy Invite Link";
        }, 2000);
      })
      .catch((err) => {
        console.error("Failed to copy text: ", err);
      });
  }
}
