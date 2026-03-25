import { ViewHook } from "phoenix_live_view";
import {
  computePosition,
  offset,
  flip,
  shift,
  autoUpdate,
  size,
} from "@floating-ui/dom";

export default class Popover extends ViewHook {
  expanded = false;
  name = "popover";
  placement = "bottom-start";
  defaultPlacement = "bottom-start";
  activePlacement = "bottom-start";
  strategy = "absolute"; // floating-ui strategy
  event_trigger = "click"; // "click" | "hover" | "focus"
  currentIndex = -1;
  expand_popover = false; // expand popover to match width of trigger
  focus_selected = true;

  #outside_listener;
  #clear_floating;

  mounted() {
    this.defaultPlacement = this.el.dataset.placement || this.placement;
    this.activePlacement = this.defaultPlacement;
    this.placement = this.defaultPlacement;
    this.strategy = this.el.dataset.strategy || this.strategy;
    this.event_trigger = this.el.dataset.trigger || this.event_trigger;
    this.cacheElements();

    this.refreshExpanded();

    if (this.event_trigger === "click") {
      // Trigger click handler
      this.trigger?.addEventListener("click", () => {
        if (this.expanded) {
          this.closePopover();
        } else {
          this.openPopover({ placement: this.getOpenPlacement() });
        }

        this.refreshExpanded();
      });
    } else if (this.event_trigger === "hover") {
      // Trigger hover handler
      this.trigger?.addEventListener("mouseenter", () => {
        this.openPopover();
        this.refreshExpanded();
      });

      this.trigger?.addEventListener("mouseleave", () => {
        this.closePopover();
        this.refreshExpanded();
      });
    } else if (this.event_trigger === "focus") {
      // Trigger focus handler
      this.trigger?.addEventListener("focus", () => {
        this.openPopover();
        this.refreshExpanded();
      });

      this.trigger?.addEventListener("blur", () => {
        this.closePopover();
        this.refreshExpanded();
      });
    }

    // Keydown handler
    this.el.addEventListener("keydown", this.handleContainerKeyDown.bind(this));
    this.trigger?.addEventListener(
      "keydown",
      this.handleTriggerKeyDown.bind(this),
    );

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
    this.cacheElements();
    this.restoreExpanded();
    this.refreshFloatingUI();
  }

  destroyed() {
    document.removeEventListener("click", this.#outside_listener);

    if (this.#clear_floating) {
      this.#clear_floating();
    }
  }

  handleTriggerKeyDown(event) {
    if (!this.expanded && (event.key === "ArrowDown" || event.key === "ArrowUp")) {
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

  handleContainerKeyDown(event) {
    if (!this.expanded) return;

    switch (event.key) {
      case "Escape":
        event.preventDefault();
        this.closePopover();
        this.trigger?.focus();
        break;
      case "ArrowDown":
      case "ArrowUp":
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

  handleTriggerTypeahead(_event) {
    return false;
  }

  handlePrintableKey(_event) {
    return false;
  }

  handleArrowNavigation(event) {
    if (!this.expanded) return;

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

  initFloatingUI() {
    if (this.#clear_floating) {
      this.#clear_floating();
    }
    if (!this.trigger || !this.popup) {
      return;
    }
    this.#clear_floating = autoUpdate(this.trigger, this.popup, () => {
      this.refreshFloatingUI();
    });
  }

  refreshFloatingUI() {
    const expand_popover = this.expand_popover;
    const popup = this.popup;
    computePosition(this.trigger, this.popup, {
      placement: this.activePlacement,
      strategy: this.strategy,
      middleware: [
        offset(8),
        flip(),
        shift(),
        size({
          apply({ rects }) {
            if (expand_popover) {
              popup.style.width = `${rects.reference.width}px`;
            }
          },
        }),
      ],
    }).then(({ x, y, strategy }) => {
      Object.assign(this.popup.style, {
        left: `${x}px`,
        top: `${y}px`,
        position: strategy,
      });
    });
  }

  closePopover() {
    this.trigger?.setAttribute("aria-expanded", "false");
    this.popup?.setAttribute("aria-hidden", "true");

    this.expanded = false;
    this.currentIndex = -1;
    this.activePlacement = this.defaultPlacement;

    this.onPopupClosed();
    this.removeOutsideListener();
  }

  onPopupOpened() {}

  onPopupClosed() {
    if (
      this.popup?.contains(document.activeElement) ||
      this.trigger?.contains(document.activeElement)
    ) {
      this.focusElement(this.trigger);
    }
  }

  openPopover(options = {}) {
    this.activePlacement = options.placement || this.getOpenPlacement();
    this.trigger?.setAttribute("aria-expanded", "true");
    this.popup?.setAttribute("aria-hidden", "false");

    this.focusElement(this.popup);
    this.expanded = true;
    this.currentIndex = this.getInitialNavigationIndex(this.getNavigableItems());

    this.onPopupOpened();
    this.listenOutside();
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
