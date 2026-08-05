import { ViewHook } from "phoenix_live_view";

const DEFAULT_POSITION = "top-center";
const DEFAULT_TIMEOUT = 5000;
const STACK_GAP = 10;
const STACK_PEEK = 12;
const MAX_STACK_INDICATORS = 3;
const REMOVAL_DURATION = 180;

export default class FlashGroup extends ViewHook {
  #timers = new Map();
  #pausedTimers = new Map();
  #hoveredFlashes = new Set();
  #focusedFlashes = new Set();
  #expandedPositions = new Set();

  mounted() {
    this._onPointerOver = this._onPointerOver.bind(this);
    this._onPointerOut = this._onPointerOut.bind(this);
    this._onFocusIn = this._onFocusIn.bind(this);
    this._onFocusOut = this._onFocusOut.bind(this);
    this._onClick = this._onClick.bind(this);

    this.el.addEventListener("pointerover", this._onPointerOver);
    this.el.addEventListener("pointerout", this._onPointerOut);
    this.el.addEventListener("focusin", this._onFocusIn);
    this.el.addEventListener("focusout", this._onFocusOut);
    this.el.addEventListener("click", this._onClick);

    this._readConfig();
    this._updateFlashList();
  }

  updated() {
    this._readConfig();
    this._updateFlashList();
  }

  destroyed() {
    this.#timers.forEach((timer) => clearTimeout(timer.timer));
    this.#timers.clear();
    this.#pausedTimers.clear();
    this.#hoveredFlashes.clear();
    this.#focusedFlashes.clear();
    this.#expandedPositions.clear();

    this.el.removeEventListener("pointerover", this._onPointerOver);
    this.el.removeEventListener("pointerout", this._onPointerOut);
    this.el.removeEventListener("focusin", this._onFocusIn);
    this.el.removeEventListener("focusout", this._onFocusOut);
    this.el.removeEventListener("click", this._onClick);
  }

  _readConfig() {
    this.stacked = this.el.dataset.stacked !== "false";
    this.flashTimeout = this._numberFrom(
      this.el.dataset.flashTimeout,
      DEFAULT_TIMEOUT,
    );
  }

  _onPointerOver(event) {
    const flash = this._flashFromEvent(event);

    if (!flash || (event.relatedTarget && flash.contains(event.relatedTarget))) {
      return;
    }

    this.#hoveredFlashes.add(flash);
    this.#expandedPositions.add(this._positionFor(flash));
    this._pauseTimer(flash);
    this._updateFlashList();
  }

  _onPointerOut(event) {
    const flash = this._flashFromEvent(event);

    if (!flash || (event.relatedTarget && flash.contains(event.relatedTarget))) {
      return;
    }

    const nextFlash = this._flashFromTarget(event.relatedTarget);

    if (
      nextFlash &&
      this._positionFor(nextFlash) === this._positionFor(flash)
    ) {
      this.#hoveredFlashes.delete(flash);
      this.#hoveredFlashes.add(nextFlash);
      this._resumeTimer(flash);
      this._pauseTimer(nextFlash);
      this._updateFlashList();
      return;
    }

    this.#hoveredFlashes.delete(flash);
    this._collapsePositionWhenIdle(flash);
    this._resumeTimer(flash);
    this._updateFlashList();
  }

  _onFocusIn(event) {
    const flash = this._flashFromEvent(event);

    if (!flash) {
      return;
    }

    this.#focusedFlashes.add(flash);
    this.#expandedPositions.add(this._positionFor(flash));
    this._pauseTimer(flash);
    this._updateFlashList();
  }

  _onFocusOut(event) {
    const flash = this._flashFromEvent(event);

    if (!flash || (event.relatedTarget && flash.contains(event.relatedTarget))) {
      return;
    }

    this.#focusedFlashes.delete(flash);
    this._collapsePositionWhenIdle(flash);
    this._resumeTimer(flash);
    this._updateFlashList();
  }

  _onClick(event) {
    const target =
      event.target instanceof Element ? event.target : event.target?.parentElement;
    const closeButton = target?.closest("[data-close]");

    const flash = closeButton?.closest('[role="alert"]');

    if (
      !closeButton ||
      !flash ||
      !this.el.contains(closeButton) ||
      flash.dataset.behind === "true"
    ) {
      return;
    }

    event.preventDefault();
    this._removeFlash(flash);
  }

  _flashFromEvent(event) {
    return this._flashFromTarget(event.target);
  }

  _flashFromTarget(target) {
    target = target instanceof Element ? target : target?.parentElement;
    const flash = target?.closest('[role="alert"]');

    return flash && this.el.contains(flash) ? flash : null;
  }

  _collapsePositionWhenIdle(flash) {
    const position = this._positionFor(flash);
    const active = (element) =>
      this.#hoveredFlashes.has(element) || this.#focusedFlashes.has(element);
    const stillActive = Array.from(
      this.el.querySelectorAll('[role="alert"]'),
    ).some((element) => this._positionFor(element) === position && active(element));

    if (!stillActive) {
      this.#expandedPositions.delete(position);
    }
  }

  _removeFlash(flash) {
    if (!flash || flash.dataset.removing === "true") {
      return;
    }

    flash.dataset.removing = "true";
    this._clearTimer(flash);
    this.#hoveredFlashes.delete(flash);
    this.#focusedFlashes.delete(flash);

    if (
      this.el.dataset.liveComponent === "true" &&
      flash.isConnected &&
      this.liveSocket?.isConnected()
    ) {
      this.pushEventTo(this.el, "dismiss_flash", {
        id: flash.dataset.flashDomId || flash.id,
      });
    }

    const direction = this._positionFor(flash).startsWith("bottom-") ? 1 : -1;
    flash.style.transition =
      "transform 180ms ease-in-out, opacity 180ms ease-in-out";
    flash.style.transform =
      "translate3d(0, " + direction * 8 + "px, 0) scale(0.96)";
    flash.style.opacity = "0";

    let removed = false;
    const finish = () => {
      if (removed) {
        return;
      }

      removed = true;
      flash.removeEventListener("transitionend", finish);
      flash.remove();
      this._updateFlashList();
    };

    flash.addEventListener("transitionend", finish);
    setTimeout(finish, REMOVAL_DURATION + 40);
  }

  _clearTimer(flash) {
    const key = this._flashKey(flash);
    const timer = this.#timers.get(key);

    if (timer) {
      clearTimeout(timer.timer);
      this.#timers.delete(key);
    }

    this.#pausedTimers.delete(key);
  }

  _flashKey(flash) {
    return flash.dataset.flashDomId || flash.id || flash.dataset.flashId;
  }

  _timeoutFor(flash) {
    if (flash.dataset.autoDismiss === "false") {
      return 0;
    }

    if (flash.dataset.timeout !== undefined && flash.dataset.timeout !== "") {
      return Math.max(this._numberFrom(flash.dataset.timeout, 0), 0);
    }

    if (flash.dataset.duration !== undefined && flash.dataset.duration !== "") {
      const duration = this._numberFrom(flash.dataset.duration, 0);
      return duration < 0 ? 0 : Math.max(duration * 1000, 0);
    }

    return Math.max(this.flashTimeout, 0);
  }

  _syncTimer(flash) {
    const key = this._flashKey(flash);
    const timeout = this._timeoutFor(flash);
    const current = this.#timers.get(key);
    const paused = this.#pausedTimers.get(key);

    if (timeout <= 0) {
      this._clearTimer(flash);
      return;
    }

    if (current?.timeout === timeout || paused?.timeout === timeout) {
      return;
    }

    this._clearTimer(flash);

    if (this.#hoveredFlashes.has(flash) || this.#focusedFlashes.has(flash)) {
      this.#pausedTimers.set(key, { remaining: timeout, timeout });
      return;
    }

    this._startTimerForFlash(flash, timeout);
  }

  _startTimerForFlash(flash, timeout, remaining = timeout) {
    const key = this._flashKey(flash);
    const startTime = Date.now();
    let timer;

    timer = setTimeout(() => {
      const current = this.#timers.get(key);

      if (current?.timer === timer) {
        this.#timers.delete(key);
        this._removeFlash(flash);
      }
    }, Math.max(remaining, 0));

    this.#timers.set(key, { timer, startTime, timeout });
  }

  _pauseTimer(flash) {
    const key = this._flashKey(flash);
    const current = this.#timers.get(key);

    if (!current) {
      return;
    }

    clearTimeout(current.timer);
    this.#timers.delete(key);
    this.#pausedTimers.set(key, {
      remaining: Math.max(current.timeout - (Date.now() - current.startTime), 0),
      timeout: current.timeout,
    });
  }

  _resumeTimer(flash) {
    if (this.#hoveredFlashes.has(flash) || this.#focusedFlashes.has(flash)) {
      return;
    }

    const key = this._flashKey(flash);
    const paused = this.#pausedTimers.get(key);

    if (!paused) {
      return;
    }

    this.#pausedTimers.delete(key);

    if (paused.remaining <= 0) {
      this._removeFlash(flash);
      return;
    }

    this._startTimerForFlash(flash, paused.timeout, paused.remaining);
  }

  _updateFlashList() {
    const flashes = Array.from(
      this.el.querySelectorAll('[role="alert"]'),
    ).filter((flash) => flash.dataset.removing !== "true");
    const activeFlashes = new Set(flashes);

    this.#hoveredFlashes.forEach((flash) => {
      if (!activeFlashes.has(flash)) this.#hoveredFlashes.delete(flash);
    });
    this.#focusedFlashes.forEach((flash) => {
      if (!activeFlashes.has(flash)) this.#focusedFlashes.delete(flash);
    });

    const groups = new Map();

    flashes.forEach((flash) => {
      const position = this._positionFor(flash);
      const group = groups.get(position) || [];
      group.push(flash);
      groups.set(position, group);
    });

    groups.forEach((group, position) => {
      this._layoutGroup(group, position);
    });

    flashes.forEach((flash) => this._syncTimer(flash));
  }

  _layoutGroup(group, position) {
    const expanded = !this.stacked || this.#expandedPositions.has(position);
    const bottom = position.startsWith("bottom-");
    const heights = group.map((flash) => {
      flash.style.removeProperty("height");
      return Math.max(flash.offsetHeight, 1);
    });
    const frontHeight = heights[0] || 1;
    let offset = 0;

    group.forEach((flash, index) => {
      const behind = this.stacked && !expanded && index > 0;
      const visible = expanded || index <= MAX_STACK_INDICATORS;
      const translation = expanded
        ? bottom
          ? -offset
          : offset
        : bottom
          ? -index * STACK_PEEK
          : index * STACK_PEEK;
      const scale = behind ? Math.max(0.92, 1 - index * 0.025) : 1;
      const expandedContent = expanded || !behind;
      const content = flash.querySelector(".flash-content");
      const firstRender = flash.dataset.mounted !== "true";

      this._ignoreClientAttributes(flash, content);

      flash.dataset.mounted = "true";
      flash.dataset.index = String(index);
      flash.dataset.behind = String(behind);
      flash.dataset.expanded = String(expanded);
      flash.dataset.visible = String(visible);
      flash.style.setProperty("--flash-index", String(index));
      flash.style.setProperty("--flash-height", heights[index] + "px");
      flash.style.setProperty("--flash-offset-y", translation + "px");
      flash.style.setProperty("--flash-scale", String(scale));
      flash.style.height = behind ? frontHeight + "px" : "";
      flash.style.transform =
        "translate3d(0, " + translation + "px, 0) scale(" + scale + ")";
      flash.setAttribute("aria-hidden", !visible || behind ? "true" : "false");
      flash.inert = !visible;

      if (content) {
        content.dataset.behind = String(behind);
        content.dataset.expanded = String(expandedContent);
        content.inert = behind;
      }

      const closeButton = flash.querySelector("[data-close]");

      if (closeButton) {
        closeButton.dataset.behind = String(behind);
        closeButton.tabIndex = behind ? -1 : 0;
      }

      if (firstRender) {
        const initialTranslation = bottom ? "200%" : "-200%";
        flash.style.transition = "none";
        flash.style.transform =
          "translate3d(0, " + initialTranslation + ", 0) scale(" + scale + ")";

        requestAnimationFrame(() => {
          if (!flash.isConnected || flash.dataset.removing === "true") {
            return;
          }

          flash.style.transition = "";
          flash.style.transform =
            "translate3d(0, " + translation + "px, 0) scale(" + scale + ")";
        });
      }

      if (expanded) {
        offset += heights[index] + STACK_GAP;
      }
    });
  }

  _ignoreClientAttributes(flash, content) {
    if (flash.phxPrivate?.["JS:ignore_attrs"] == null) {
      this.js().ignoreAttributes(flash, [
        "aria-hidden",
        "data-behind",
        "data-index",
        "data-mounted",
        "data-removing",
        "data-expanded",
        "data-visible",
        "inert",
        "style",
      ]);
    }

    if (content && content.phxPrivate?.["JS:ignore_attrs"] == null) {
      this.js().ignoreAttributes(content, [
        "data-behind",
        "data-expanded",
        "inert",
      ]);
    }

    const closeButton = flash.querySelector("[data-close]");

    if (closeButton && closeButton.phxPrivate?.["JS:ignore_attrs"] == null) {
      this.js().ignoreAttributes(closeButton, ["data-behind", "tabindex"]);
    }
  }

  _positionFor(flash) {
    return flash.dataset.position || this.el.dataset.position || DEFAULT_POSITION;
  }

  _numberFrom(value, fallback) {
    const number = Number(value);
    return Number.isFinite(number) ? number : fallback;
  }
}
