import { ViewHook } from "phoenix_live_view";

const State = {
  IDLE: 0,
  STARTING: 1,
};

export default class LoadingBar extends ViewHook {
  progress = 0;

  delay = 300;
  delayTimer = null;
  resetTimer = null;
  raf = null;
  state = State.IDLE;
  #boundShow = null;
  #boundHide = null;

  mounted() {
    this.progressEl = this.el.querySelector("#loadingbar-progress");
    this.delay = this.parseDelay(this.el.dataset.delay);

    this.#boundShow = this._show.bind(this);
    this.#boundHide = this._hide.bind(this);
    this.state = State.IDLE;

    window.addEventListener("phx:page-loading-start", this.#boundShow);
    window.addEventListener("phx:page-loading-stop", this.#boundHide);
  }

  parseDelay(value) {
    const parsed = Number.parseInt(value, 10);
    return Number.isFinite(parsed) && parsed >= 0 ? parsed : this.delay;
  }

  _show() {
    this._clear();

    this.delayTimer = setTimeout(() => {
      this.delayTimer = null;
      if (this.state === State.IDLE) {
        this.state = State.STARTING;
        this._start();
      }
    }, this.delay);
  }

  _start() {
    let lastTime = performance.now();

    const step = (now) => {
      const dt = now - lastTime;
      lastTime = now;
      if (this.progress < 50) {
        const delta = (100 - this.progress) * 0.01 * (dt / 16);
        this.progress = Math.min(this.progress + delta, 50);
      } else if (this.progress < 90) {
        const delta = (100 - this.progress) * 0.0025 * (dt / 16);
        this.progress = Math.min(this.progress + delta, 90);
      } else if (this.progress < 99) {
        const delta = (100 - this.progress) * 0.0005 * (dt / 16);
        this.progress = Math.min(this.progress + delta, 99);
      }

      this.progressEl.style.width = `${this.progress}%`;
      this.raf = requestAnimationFrame(step);
    };

    this.raf = requestAnimationFrame(step);
  }

  _reset() {
    this.progressEl.style.transition = "none";
    this.progressEl.style.width = "0%";
    this.progressEl.offsetHeight; // force reflow
    this.progressEl.style.transition = "";
    this.progress = 0;

    this._clear();

    this.state = State.IDLE;

    cancelAnimationFrame(this.raf);
    this.raf = null;
  }

  _hide() {
    this.state = State.IDLE;
    this._clear();

    cancelAnimationFrame(this.raf);
    this.raf = null;

    if (this.progress > 0) {
      this.progress = 100;
      this.progressEl.style.width = "100%";
    }

    this.resetTimer = setTimeout(() => {
      this.resetTimer = null;
      this._reset();
    }, 500);
  }

  _clear() {
    if (this.delayTimer !== null) {
      clearTimeout(this.delayTimer);
      this.delayTimer = null;
    }

    if (this.resetTimer !== null) {
      clearTimeout(this.resetTimer);
      this.resetTimer = null;
    }
  }

  destroyed() {
    this._clear();
    cancelAnimationFrame(this.raf);
    this.raf = null;

    window.removeEventListener("phx:page-loading-start", this.#boundShow);
    window.removeEventListener("phx:page-loading-stop", this.#boundHide);
  }
}
