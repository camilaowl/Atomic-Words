// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import { hooks as colocatedHooks } from "phoenix-colocated/atomic_words"
import topbar from "../vendor/topbar"

const FlashcardSwipe = {
  mounted() {
    this.cardEl = this.el.querySelector(".flashcard-current")
    this.actionButtons = this.el.querySelectorAll("[data-flashcard-action]")
    this.flashcardId = this.el.dataset.flashcardId
    this.isAnimating = false
    this.isDragging = false
    this.hasMoved = false
    this.suppressClick = false

    this.handleButtonClick = event => {
      if (this.isAnimating) return
      event.preventDefault()
      const action = event.currentTarget.dataset.flashcardAction
      const direction = action === "right" ? "right" : "left"
      this.commitSwipe(direction)
    }

    this.handlePointerDown = event => {
      if (!this.cardEl || this.isAnimating) return
      if (event.button !== undefined && event.button !== 0) return

      this.isDragging = true
      this.hasMoved = false
      this.startX = event.clientX
      this.currentX = event.clientX
      this.cardEl.classList.add("dragging")
      this.cardEl.setPointerCapture(event.pointerId)
    }

    this.handlePointerMove = event => {
      if (!this.isDragging) return
      this.currentX = event.clientX
      const deltaX = this.currentX - this.startX
      if (Math.abs(deltaX) > 6) this.hasMoved = true

      const rotate = Math.max(Math.min(deltaX / 18, 12), -12)
      const opacity = Math.max(1 - Math.abs(deltaX) / 360, 0.2)
      this.cardEl.style.transform = `translateX(${deltaX}px) rotate(${rotate}deg)`
      this.cardEl.style.opacity = opacity
    }

    this.handlePointerUp = event => {
      if (!this.isDragging) return
      this.isDragging = false
      this.cardEl.releasePointerCapture(event.pointerId)
      this.cardEl.classList.remove("dragging")

      const deltaX = this.currentX - this.startX
      const threshold = 90
      if (Math.abs(deltaX) >= threshold) {
        this.suppressClick = true
        const direction = deltaX > 0 ? "right" : "left"
        this.commitSwipe(direction)
      } else {
        this.suppressClick = this.hasMoved
        this.resetCard()
      }
    }

    this.handleCardClick = event => {
      if (!this.suppressClick) return
      event.preventDefault()
      event.stopImmediatePropagation()
      this.suppressClick = false
    }

    this.bindCardListeners()

    this.actionButtons.forEach(button => {
      button.addEventListener("click", this.handleButtonClick)
    })
  },

  updated() {
    const nextCardEl = this.el.querySelector(".flashcard-current")
    if (nextCardEl !== this.cardEl) {
      this.unbindCardListeners()
      this.cardEl = nextCardEl
      this.bindCardListeners()
    }

    this.actionButtons.forEach(button => {
      button.removeEventListener("click", this.handleButtonClick)
    })
    this.actionButtons = this.el.querySelectorAll("[data-flashcard-action]")
    this.actionButtons.forEach(button => {
      button.addEventListener("click", this.handleButtonClick)
    })

    this.flashcardId = this.el.dataset.flashcardId
    this.resetCard()
  },

  destroyed() {
    this.unbindCardListeners()

    this.actionButtons.forEach(button => {
      button.removeEventListener("click", this.handleButtonClick)
    })
  },

  bindCardListeners() {
    if (!this.cardEl) return
    this.cardEl.addEventListener("pointerdown", this.handlePointerDown)
    this.cardEl.addEventListener("pointermove", this.handlePointerMove)
    this.cardEl.addEventListener("pointerup", this.handlePointerUp)
    this.cardEl.addEventListener("pointercancel", this.handlePointerUp)
    this.cardEl.addEventListener("click", this.handleCardClick)
  },

  unbindCardListeners() {
    if (!this.cardEl) return
    this.cardEl.removeEventListener("pointerdown", this.handlePointerDown)
    this.cardEl.removeEventListener("pointermove", this.handlePointerMove)
    this.cardEl.removeEventListener("pointerup", this.handlePointerUp)
    this.cardEl.removeEventListener("pointercancel", this.handlePointerUp)
    this.cardEl.removeEventListener("click", this.handleCardClick)
  },

  commitSwipe(direction) {
    if (!this.cardEl || this.isAnimating) return
    this.isAnimating = true
    this.cardEl.classList.remove("swipe-left", "swipe-right")
    this.cardEl.style.transform = ""
    this.cardEl.style.opacity = ""
    this.cardEl.classList.add(direction === "right" ? "swipe-right" : "swipe-left")

    const eventName = direction === "right" ? "right_answer" : "wrong_answer"
    window.setTimeout(() => {
      this.pushEvent(eventName, { id: this.flashcardId })
    }, 300)
  },

  resetCard() {
    if (!this.cardEl) return
    this.isAnimating = false
    this.cardEl.classList.remove("swipe-left", "swipe-right", "dragging")
    this.cardEl.style.transform = ""
    this.cardEl.style.opacity = ""
  },
}

const ThemeToggle = {
  mounted() {
    const updateChecked = () => {
      const theme = document.documentElement.getAttribute("data-theme")
      this.el.checked = theme === "dark"
    }
    updateChecked()

    this._observer = new MutationObserver(updateChecked)
    this._observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ["data-theme"]
    })

    this.el.addEventListener("change", () => {
      const theme = this.el.checked ? "dark" : "light"
      localStorage.setItem("theme", theme)
      document.documentElement.setAttribute("data-theme", theme)
    })
  },
  destroyed() {
    this._observer?.disconnect()
  }
}

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: { ...colocatedHooks, FlashcardSwipe, ThemeToggle },
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({ detail: reloader }) => {
    // Enable server log streaming to client.
    // Disable with reloader.disableServerLogs()
    reloader.enableServerLogs()

    // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
    //
    //   * click with "c" key pressed to open at caller location
    //   * click with "d" key pressed to open at function component definition location
    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup", e => keyDown = null)
    window.addEventListener("click", e => {
      if (keyDown === "c") {
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if (keyDown === "d") {
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)

    window.liveReloader = reloader
  })
}

