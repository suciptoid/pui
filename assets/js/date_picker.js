import { ViewHook } from "phoenix_live_view";
import {
  computePosition,
  offset,
  flip,
  shift,
  autoUpdate,
  getOverflowAncestors,
  hide,
  size,
} from "@floating-ui/dom";

export default class DatePicker extends ViewHook {
  expanded = false;
  name = "date-picker";
  placement = "bottom-start";
  defaultPlacement = "bottom-start";
  activePlacement = "bottom-start";
  strategy = "auto"; // "auto" | "absolute" | "fixed"
  defaultStrategy = "absolute";
  currentStrategy = "absolute";
  event_trigger = "click"; // "click" | "hover" | "focus"
  currentIndex = -1;
  expand_popover = false; // expand popover to match width of trigger
  focus_selected = true;
  pendingCalendarFocusDate = null;

  #outside_listener;
  #clear_floating;
  #triggerClickHandler;
  #triggerMouseEnterHandler;
  #triggerMouseLeaveHandler;
  #triggerFocusHandler;
  #triggerBlurHandler;
  #containerKeyDownHandler;
  #triggerKeyDownHandler;
  #externalCloseHandler;
  #inputSyncHandler;
  #selectChangeHandler;

  mounted() {
    this.defaultPlacement = this.el.dataset.placement || this.placement;
    this.activePlacement = this.defaultPlacement;
    this.placement = this.defaultPlacement;
    this.strategy = this.el.dataset.strategy || this.strategy;
    this.currentStrategy = this.resolveStrategy();
    this.event_trigger = this.el.dataset.trigger || this.event_trigger;
    this.cacheElements();

    this.refreshExpanded();

    this.#triggerClickHandler = this.handleTriggerClick.bind(this);
    this.#triggerMouseEnterHandler = this.handleTriggerMouseEnter.bind(this);
    this.#triggerMouseLeaveHandler = this.handleTriggerMouseLeave.bind(this);
    this.#triggerFocusHandler = this.handleTriggerFocus.bind(this);
    this.#triggerBlurHandler = this.handleTriggerBlur.bind(this);
    this.#containerKeyDownHandler = this.handleContainerKeyDown.bind(this);
    this.#triggerKeyDownHandler = this.handleTriggerKeyDown.bind(this);
    this.#externalCloseHandler = this.handleExternalClose.bind(this);
    this.#inputSyncHandler = this.handleInputSync.bind(this);
    this.#selectChangeHandler = this.handleSelectChange.bind(this);

    this.bindEventListeners();
    this.el.addEventListener("pui:popover-close", this.#externalCloseHandler);
    this.el.addEventListener("pui:date-picker-sync", this.#inputSyncHandler);
    this.el.addEventListener("change", this.#selectChangeHandler);
    this.ignoreHookManagedAttributes();

    this.#outside_listener = (event) => {
      const target = event.target;
      const clickedOnTrigger = this.trigger?.contains(target);
      const clickedOnPopup = this.popup?.contains(target);
      if (!clickedOnTrigger && !clickedOnPopup && this.expanded) {
        this.closePopover();
      }
    };

    this.initFloatingUI();
  }

  listenOutside() {
    document.addEventListener("click", this.#outside_listener);
  }

  removeOutsideListener() {
    document.removeEventListener("click", this.#outside_listener);
  }

  updated() {
    const previousTrigger = this.trigger;

    this.cacheElements();
    this.ignoreHookManagedAttributes();
    this.rebindEventListeners(previousTrigger);
    this.restoreExpanded();
    this.initFloatingUI();
    this.refreshFloatingUI();
    this.restorePendingCalendarFocus();
  }

  destroyed() {
    this.unbindEventListeners(this.trigger);
    document.removeEventListener("click", this.#outside_listener);
    this.el.removeEventListener("pui:popover-close", this.#externalCloseHandler);
    this.el.removeEventListener("pui:date-picker-sync", this.#inputSyncHandler);
    this.el.removeEventListener("change", this.#selectChangeHandler);

    if (this.#clear_floating) {
      this.#clear_floating();
    }
  }

  handleTriggerKeyDown(event) {
    if (
      !this.expanded &&
      (event.key === "ArrowDown" || event.key === "ArrowUp")
    ) {
      event.preventDefault();
      this.openPopover({ placement: this.getPlacementForKey(event.key) });
      return;
    }

    if (!this.expanded && this.isPrintableKeyEvent(event)) {
      const handled = this.handleTriggerTypeahead(event);
      if (handled) {
        event.preventDefault();
      }
    }
  }

  handleTriggerClick() {
    if (this.expanded) {
      this.closePopover();
    } else {
      this.openPopover({ placement: this.getOpenPlacement() });
    }

    this.refreshExpanded();
  }

  handleTriggerMouseEnter() {
    this.openPopover();
    this.refreshExpanded();
  }

  handleTriggerMouseLeave() {
    this.closePopover();
    this.refreshExpanded();
  }

  handleTriggerFocus() {
    this.openPopover();
    this.refreshExpanded();
  }

  handleTriggerBlur() {
    this.closePopover();
    this.refreshExpanded();
  }

  handleContainerKeyDown(event) {
    if (!this.expanded) return;

    if (["SELECT", "INPUT", "TEXTAREA"].includes(event.target?.tagName)) {
      return;
    }

    switch (event.key) {
      case "Escape":
        event.preventDefault();
        event.stopPropagation();
        this.closePopover();
        this.trigger?.focus();
        break;
      case "ArrowDown":
      case "ArrowUp":
      case "ArrowLeft":
      case "ArrowRight":
      case "Home":
      case "End":
        this.handleArrowNavigation(event);
        break;
      case "Enter":
        this.handleKeyEnter(event);

        break;
      case "Tab":
        this.closePopover();
        break;
      default:
        if (this.isPrintableKeyEvent(event)) {
          const handled = this.handlePrintableKey(event);
          if (handled) {
            event.preventDefault();
          }
        }
    }
  }

  handleKeyEnter(event) {
    // see select.js for example
  }

  handleExternalClose() {
    if (!this.expanded) return;

    this.closePopover();
    this.refreshExpanded();
  }

  handleInputSync(event) {
    const inputId = event.detail?.input;
    const input = inputId ? document.getElementById(inputId) : null;

    if (!input) {
      return;
    }

    input.dispatchEvent(new Event("input", { bubbles: true }));
    input.dispatchEvent(new Event("change", { bubbles: true }));
  }

  handleSelectChange(event) {
    const target = event.target;

    if (!(target instanceof HTMLSelectElement)) {
      return;
    }

    const offset = target.dataset.offset;

    if (target.dataset.pui === "calendar-month-select") {
      event.stopPropagation();
      this.pushEventTo(this.el, "select_month", {
        month: target.value,
        offset,
      });
      return;
    }

    if (target.dataset.pui === "calendar-year-select") {
      event.stopPropagation();
      this.pushEventTo(this.el, "select_year", {
        year: target.value,
        offset,
      });
    }
  }

  handleTriggerTypeahead(_event) {
    return false;
  }

  handlePrintableKey(_event) {
    return false;
  }

  handleArrowNavigation(event) {
    if (!this.expanded) return;

    if (
      this.popup?.dataset.gridNavigation === "calendar" &&
      ["ArrowLeft", "ArrowRight", "ArrowUp", "ArrowDown"].includes(event.key)
    ) {
      event.preventDefault();
      this.handleCalendarArrowNavigation(event.key);
      return;
    }

    const visibleItems = this.getNavigableItems();
    const itemCount = visibleItems.length;

    if (itemCount === 0) return;

    event.preventDefault();

    let newIndex = this.currentIndex;

    switch (event.key) {
      case "ArrowDown":
        newIndex = (this.currentIndex + 1) % itemCount;
        break;
      case "ArrowUp":
        newIndex = (this.currentIndex - 1 + itemCount) % itemCount;
        break;
      case "Home":
        newIndex = 0;
        break;
      case "End":
        newIndex = itemCount - 1;
        break;
    }

    this.setCurrentItemByIndex(newIndex, visibleItems);
  }

  handleCalendarArrowNavigation(key) {
    const items = this.getNavigableItems();
    const currentIndex =
      this.currentIndex === -1
        ? this.getInitialNavigationIndex(items)
        : this.currentIndex;
    const currentItem = items[currentIndex];
    const currentDate = currentItem?.dataset?.date;

    if (!currentDate) {
      return;
    }

    const dayOffset =
      key === "ArrowLeft"
        ? -1
        : key === "ArrowRight"
          ? 1
          : key === "ArrowUp"
            ? -7
            : 7;

    const targetDate = this.addDays(currentDate, dayOffset);
    const targetIndex = this.findCalendarTargetIndex(
      items,
      currentIndex,
      targetDate,
      key,
    );

    if (targetIndex !== -1) {
      this.setCurrentItemByIndex(targetIndex, items);
      return;
    }

    const direction = dayOffset < 0 ? "prev" : "next";
    const navButton = this.popup?.querySelector(`[data-pui="calendar-${direction}"]`);

    if (!navButton || navButton.disabled) {
      return;
    }

    this.pendingCalendarFocusDate = targetDate;
    this.pushEventTo(this.el, "navigate", { direction });
  }

  initFloatingUI() {
    if (this.#clear_floating) {
      this.#clear_floating();
    }
    if (!this.trigger || !this.popup) {
      return;
    }

    if (!this.expanded) {
      return;
    }

    this.currentStrategy = this.resolveStrategy();

    this.#clear_floating = autoUpdate(
      this.trigger,
      this.popup,
      () => {
        this.refreshFloatingUI();
      },
      {
        animationFrame: this.currentStrategy === "fixed",
      },
    );
  }

  bindEventListeners() {
    this.el.addEventListener("keydown", this.#containerKeyDownHandler);
    this.trigger?.addEventListener("keydown", this.#triggerKeyDownHandler);

    if (this.event_trigger === "click") {
      this.trigger?.addEventListener("click", this.#triggerClickHandler);
      return;
    }

    if (this.event_trigger === "hover") {
      this.trigger?.addEventListener(
        "mouseenter",
        this.#triggerMouseEnterHandler,
      );
      this.trigger?.addEventListener(
        "mouseleave",
        this.#triggerMouseLeaveHandler,
      );
      return;
    }

    if (this.event_trigger === "focus") {
      this.trigger?.addEventListener("focus", this.#triggerFocusHandler);
      this.trigger?.addEventListener("blur", this.#triggerBlurHandler);
    }
  }

  unbindEventListeners(trigger) {
    this.el.removeEventListener("keydown", this.#containerKeyDownHandler);
    trigger?.removeEventListener("keydown", this.#triggerKeyDownHandler);
    trigger?.removeEventListener("click", this.#triggerClickHandler);
    trigger?.removeEventListener("mouseenter", this.#triggerMouseEnterHandler);
    trigger?.removeEventListener("mouseleave", this.#triggerMouseLeaveHandler);
    trigger?.removeEventListener("focus", this.#triggerFocusHandler);
    trigger?.removeEventListener("blur", this.#triggerBlurHandler);
  }

  rebindEventListeners(previousTrigger) {
    if (previousTrigger === this.trigger) {
      return;
    }

    this.unbindEventListeners(previousTrigger);
    this.bindEventListeners();
  }

  refreshFloatingUI() {
    if (!this.trigger || !this.popup || !this.expanded) {
      return Promise.resolve();
    }

    const expand_popover = this.expand_popover;
    const collisionPadding = 8;
    const nextStrategy = this.resolveStrategy();

    if (nextStrategy !== this.currentStrategy) {
      this.currentStrategy = nextStrategy;
      this.initFloatingUI();
    } else {
      this.currentStrategy = nextStrategy;
    }

    return computePosition(this.trigger, this.popup, {
      placement: this.activePlacement,
      strategy: this.currentStrategy,
      middleware: [
        offset(collisionPadding),
        flip({ padding: collisionPadding }),
        shift({ padding: collisionPadding }),
        size({
          padding: collisionPadding,
          apply({ rects, elements }) {
            if (expand_popover) {
              elements.floating.style.width = `${Math.max(0, Math.floor(rects.reference.width))}px`;
            } else {
              elements.floating.style.removeProperty("width");
            }
          },
        }),
        hide({ padding: collisionPadding }),
      ],
    }).then(({ x, y, strategy, placement, middlewareData }) => {
      const referenceHidden = Boolean(middlewareData.hide?.referenceHidden);

      Object.assign(this.popup.style, {
        left: `${x}px`,
        top: `${y}px`,
        position: strategy,
      });

      this.popup.dataset.side = placement.split("-")[0];
      this.popup.dataset.floatingStrategy = strategy;
      this.popup.dataset.referenceHidden = String(referenceHidden);

      if (referenceHidden && this.expanded) {
        this.closePopover({ restoreFocus: false });
      }
    });
  }

  closePopover(options = {}) {
    const { restoreFocus = true } = options;

    this.trigger?.setAttribute("aria-expanded", "false");
    this.popup?.setAttribute("aria-hidden", "true");

    this.expanded = false;
    this.currentIndex = -1;
    this.activePlacement = this.defaultPlacement;

    this.onPopupClosed(restoreFocus);
    this.popup?.setAttribute("data-reference-hidden", "false");
    this.removeOutsideListener();
    this.initFloatingUI();
  }

  onPopupOpened() {}

  onPopupClosed(restoreFocus = true) {
    if (
      this.popup?.contains(document.activeElement) ||
      this.trigger?.contains(document.activeElement)
    ) {
      if (restoreFocus) {
        this.focusElement(this.trigger);
      } else if (typeof document.activeElement?.blur === "function") {
        document.activeElement.blur();
      }
    }
  }

  openPopover(options = {}) {
    this.activePlacement = options.placement || this.getOpenPlacement();
    this.trigger?.setAttribute("aria-expanded", "true");
    this.popup?.setAttribute("aria-hidden", "false");
    this.popup?.setAttribute("data-reference-hidden", "false");

    this.focusElement(this.popup);
    this.expanded = true;
    this.currentIndex = this.getInitialNavigationIndex(
      this.getNavigableItems(),
    );

    this.onPopupOpened();
    this.listenOutside();
    this.initFloatingUI();
    this.refreshFloatingUI();

    requestAnimationFrame(() => {
      if (!this.expanded) return;

      if (this.currentIndex !== -1) {
        this.setCurrentItemByIndex(this.currentIndex);
      } else {
        this.focusElement(this.popup);
      }
    });
  }

  log(msg, data) {
    console.log(`${this.name}: ${msg}`, data);
  }

  refreshExpanded() {
    this.expanded = this.trigger?.getAttribute("aria-expanded") == "true";
  }

  restoreExpanded() {
    if (this.expanded) {
      this.openPopover({ placement: this.activePlacement });
    } else {
      this.closePopover();
    }
  }

  cacheElements() {
    this.trigger = this.el.querySelector("[aria-haspopup],[role='combobox']");
    this.popup = this.el.querySelector("[role='menu'],[role='listbox']");
    this.items =
      this.popup?.querySelectorAll("[role='option'],[role='menuitem']") ?? [];
  }

  ignoreHookManagedAttributes() {
    if (this.trigger) {
      this.js().ignoreAttributes(this.trigger, ["aria-expanded"]);
    }

    if (this.popup) {
      this.js().ignoreAttributes(this.popup, ["aria-*", "data-*", "style"]);
    }
  }

  getOpenPlacement() {
    return this.defaultPlacement;
  }

  getPlacementForKey(_key) {
    return this.defaultPlacement;
  }

  getNavigableItems() {
    return Array.from(this.items).filter(
      (item) =>
        item.style.display !== "none" &&
        item.getAttribute("aria-disabled") !== "true" &&
        item.getAttribute("aria-hidden") !== "true",
    );
  }

  getInitialNavigationIndex(items) {
    const focusDate = this.popup?.dataset.focusDate;

    if (focusDate) {
      const focusedIndex = items.findIndex((item) => item.dataset?.date === focusDate);
      if (focusedIndex !== -1) {
        return focusedIndex;
      }
    }

    return items.length > 0 ? 0 : -1;
  }

  setCurrentItemByIndex(index, items = this.getNavigableItems()) {
    const itemCount = items.length;
    if (itemCount === 0 || index < 0 || index >= itemCount) {
      this.currentIndex = -1;
      return null;
    }

    items.forEach((item, itemIndex) => {
      if (itemIndex === index) {
        item.setAttribute("aria-selected", "true");
        item.setAttribute("tabindex", "0");
        if (this.focus_selected) {
          this.focusElement(item);
        }
        this.scrollItemIntoView(item);
      } else {
        item.setAttribute("tabindex", "-1");
        item.removeAttribute("aria-selected");
      }
    });

    this.currentIndex = index;
    return items[index];
  }

  isPrintableKeyEvent(event) {
    return (
      event.key.length === 1 &&
      !event.altKey &&
      !event.ctrlKey &&
      !event.metaKey
    );
  }

  focusElement(element) {
    if (!element) {
      return;
    }

    if (typeof element.focus === "function") {
      try {
        element.focus({ preventScroll: true });
      } catch {
        element.focus();
      }
    }
  }

  restorePendingCalendarFocus() {
    if (!this.pendingCalendarFocusDate || !this.expanded) {
      return;
    }

    requestAnimationFrame(() => {
      if (!this.expanded) return;

      const items = this.getNavigableItems();
      const targetIndex = items.findIndex(
        (item) => item.dataset?.date === this.pendingCalendarFocusDate,
      );

      if (targetIndex !== -1) {
        this.setCurrentItemByIndex(targetIndex, items);
      }

      this.pendingCalendarFocusDate = null;
    });
  }

  addDays(value, offset) {
    const date = this.parseISODate(value);
    if (!date) {
      return value;
    }

    date.setUTCDate(date.getUTCDate() + offset);
    return this.formatISODate(date);
  }

  parseISODate(value) {
    const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value);

    if (!match) {
      return null;
    }

    const [, year, month, day] = match;
    const date = new Date(Date.UTC(Number(year), Number(month) - 1, Number(day)));

    return Number.isNaN(date.getTime()) ? null : date;
  }

  formatISODate(date) {
    const year = String(date.getUTCFullYear());
    const month = String(date.getUTCMonth() + 1).padStart(2, "0");
    const day = String(date.getUTCDate()).padStart(2, "0");

    return `${year}-${month}-${day}`;
  }

  findCalendarTargetIndex(items, currentIndex, targetDate, key) {
    const candidates = items
      .map((item, index) => ({ item, index }))
      .filter(({ item }) => item.dataset?.date === targetDate);

    if (candidates.length === 0) {
      return -1;
    }

    const inMonthCandidate = candidates.find(
      ({ item }) => item.dataset?.outsideMonth !== "true",
    );

    if (inMonthCandidate) {
      return inMonthCandidate.index;
    }

    if (key === "ArrowRight" || key === "ArrowDown") {
      return (
        candidates.find(({ index }) => index > currentIndex)?.index ??
        candidates[candidates.length - 1].index
      );
    }

    if (key === "ArrowLeft" || key === "ArrowUp") {
      return (
        [...candidates].reverse().find(({ index }) => index < currentIndex)?.index ??
        candidates[0].index
      );
    }

    return candidates[0].index;
  }

  resolveStrategy() {
    if (this.strategy === "absolute" || this.strategy === "fixed") {
      return this.strategy;
    }

    return this.hasNestedClippingAncestor() ? "fixed" : this.defaultStrategy;
  }

  hasNestedClippingAncestor() {
    if (!this.trigger) {
      return false;
    }

    return getOverflowAncestors(this.trigger).some((ancestor) =>
      this.isNestedClippingAncestor(ancestor),
    );
  }

  isNestedClippingAncestor(ancestor) {
    if (!(ancestor instanceof HTMLElement)) {
      return false;
    }

    const doc = ancestor.ownerDocument;

    if (
      !doc ||
      ancestor === doc.body ||
      ancestor === doc.documentElement ||
      ancestor === this.el ||
      ancestor === this.trigger ||
      ancestor === this.popup
    ) {
      return false;
    }

    const style = window.getComputedStyle(ancestor);

    return [style.overflow, style.overflowX, style.overflowY].some((value) =>
      ["auto", "scroll", "hidden", "clip", "overlay"].includes(value),
    );
  }

  scrollItemIntoView(item) {
    if (!item || !this.popup) {
      return;
    }

    const popupRect = this.popup.getBoundingClientRect();
    const itemRect = item.getBoundingClientRect();

    if (itemRect.top < popupRect.top) {
      this.popup.scrollTop -= popupRect.top - itemRect.top;
    } else if (itemRect.bottom > popupRect.bottom) {
      this.popup.scrollTop += itemRect.bottom - popupRect.bottom;
    }
  }
}
