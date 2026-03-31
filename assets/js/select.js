import { ViewHook } from "phoenix_live_view";
import {
  autoUpdate,
  computePosition,
  flip,
  offset,
  shift,
  size,
} from "@floating-ui/dom";

export default class Select extends ViewHook {
  expanded = false;
  placement = "bottom-start";
  activePlacement = "bottom-start";
  strategy = "absolute";
  currentIndex = -1;
  expandPopover = true;
  focusSelected = false;

  #clearFloating;
  #outsideListener;
  #triggerClickHandler;
  #triggerKeyDownHandler;
  #containerKeyDownHandler;
  #popupClickHandler;
  #searchInputHandler;
  #searchKeyDownHandler;
  #typeaheadBuffer = "";
  #typeaheadTimeout;

  mounted() {
    this.placement = this.el.dataset.placement || this.placement;
    this.activePlacement = this.placement;

    this.cacheElements();
    this.refreshExpanded();

    this.#triggerClickHandler = this.handleTriggerClick.bind(this);
    this.#triggerKeyDownHandler = this.handleTriggerKeyDown.bind(this);
    this.#containerKeyDownHandler = this.handleContainerKeyDown.bind(this);
    this.#popupClickHandler = this.handlePopupClick.bind(this);
    this.#searchInputHandler = this.handleSearchInput.bind(this);
    this.#searchKeyDownHandler = this.handleSearchKeyDown.bind(this);

    this.bindEventListeners();

    this.#outsideListener = (event) => {
      const target = event.target;
      const clickedOnTrigger = this.trigger?.contains(target);
      const clickedOnPopup = this.popup?.contains(target);

      if (!clickedOnTrigger && !clickedOnPopup && this.expanded) {
        this.closePopover();
      }
    };

    this.initFloatingUI();
    this.ensureOptionMetadata();
    this.selectDefaultValue();
  }

  updated() {
    const previousTrigger = this.trigger;
    const previousPopup = this.popup;
    const previousSearch = this.search;

    this.cacheElements();
    this.rebindEventListeners(previousTrigger, previousPopup, previousSearch);
    this.ensureOptionMetadata();
    this.restoreExpanded();
    this.syncValueFromDataset();
    this.initFloatingUI();
    this.refreshFloatingUI();
  }

  destroyed() {
    this.unbindEventListeners(this.trigger, this.popup, this.search);
    document.removeEventListener("click", this.#outsideListener);

    if (this.#clearFloating) {
      this.#clearFloating();
    }

    this.resetTypeahead();
  }

  cacheElements() {
    this.trigger = this.el.querySelector("[aria-haspopup],[role='combobox']");
    this.popup = this.el.querySelector("[role='menu'],[role='listbox']");
    this.items =
      this.popup?.querySelectorAll("[role='option'],[role='menuitem']") ?? [];
    this.search = this.el.querySelector(
      "input[type='text'][role='searchbox'], input[type='text'][role='combobox']",
    );
    this.hiddenInput = this.el.querySelector("input[data-pui='select-value']");
    this.label = this.el.querySelector("[data-pui='selected-label']");
  }

  bindEventListeners() {
    this.el.addEventListener("keydown", this.#containerKeyDownHandler);
    this.trigger?.addEventListener("click", this.#triggerClickHandler);
    this.trigger?.addEventListener("keydown", this.#triggerKeyDownHandler);
    this.popup?.addEventListener("click", this.#popupClickHandler);
    this.search?.addEventListener("keydown", this.#searchKeyDownHandler);
  }

  unbindEventListeners(trigger, popup, search) {
    this.el.removeEventListener("keydown", this.#containerKeyDownHandler);
    trigger?.removeEventListener("click", this.#triggerClickHandler);
    trigger?.removeEventListener("keydown", this.#triggerKeyDownHandler);
    popup?.removeEventListener("click", this.#popupClickHandler);
    search?.removeEventListener("keydown", this.#searchKeyDownHandler);
    search?.removeEventListener("input", this.#searchInputHandler);
  }

  rebindEventListeners(previousTrigger, previousPopup, previousSearch) {
    if (
      previousTrigger === this.trigger &&
      previousPopup === this.popup &&
      previousSearch === this.search
    ) {
      return;
    }

    this.unbindEventListeners(previousTrigger, previousPopup, previousSearch);
    this.bindEventListeners();

    if (this.expanded) {
      this.search?.addEventListener("input", this.#searchInputHandler);
    }
  }

  refreshExpanded() {
    this.expanded = this.trigger?.getAttribute("aria-expanded") === "true";
  }

  restoreExpanded() {
    if (this.expanded) {
      this.openPopover({ placement: this.activePlacement });
    } else {
      this.closePopover();
    }
  }

  handleTriggerClick() {
    if (this.expanded) {
      this.closePopover();
    } else {
      this.openPopover({ placement: this.placement });
    }

    this.refreshExpanded();
  }

  handleTriggerKeyDown(event) {
    if (!this.expanded && (event.key === "ArrowDown" || event.key === "ArrowUp")) {
      event.preventDefault();
      event.stopPropagation();
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
    if (!this.expanded) {
      return;
    }

    switch (event.key) {
      case "Escape":
        event.preventDefault();
        event.stopPropagation();
        this.closePopover();
        this.focusElement(this.trigger);
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

  handleArrowNavigation(event) {
    const visibleItems = this.getNavigableItems();
    const itemCount = visibleItems.length;

    if (itemCount === 0) {
      return;
    }

    event.preventDefault();

    if (this.currentIndex < 0) {
      const initialIndex = this.getInitialNavigationIndex(visibleItems);
      this.setCurrentItemByIndex(initialIndex, visibleItems);
      return;
    }

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

  handleKeyEnter(event) {
    if (this.currentIndex < 0) {
      return;
    }

    event.preventDefault();
    const visibleItems = this.getNavigableItems();
    const currentItem = visibleItems[this.currentIndex];

    if (currentItem) {
      this.selectItem(currentItem);
    }
  }

  handlePopupClick(event) {
    const item = event.target?.closest("[role='option'],[role='menuitem']");
    if (item && this.popup?.contains(item)) {
      this.selectItem(item);
    }
  }

  handleSearchInput(event) {
    event.stopPropagation();

    const query = event.target.value.toLowerCase();

    this.currentIndex = -1;
    this.items.forEach((item) => {
      const itemText = (item.dataset.label || item.textContent).trim().toLowerCase();
      const matches = itemText.includes(query);
      item.setAttribute("aria-hidden", String(!matches));
    });

    const visibleItems = this.getNavigableItems();
    const nextIndex = this.getInitialNavigationIndex(visibleItems);
    this.setCurrentItemByIndex(nextIndex, visibleItems);
  }

  handleSearchKeyDown(event) {
    switch (event.key) {
      case "ArrowDown":
      case "ArrowUp":
      case "Home":
      case "End":
      case "Enter":
      case "Escape":
        this.handleContainerKeyDown(event);
        event.stopPropagation();
        break;
    }
  }

  handleTriggerTypeahead(event) {
    const item = this.findTypeaheadMatch(event.key);

    if (!item) {
      return false;
    }

    this.selectItem(item, { close: false });
    return true;
  }

  handlePrintableKey(event) {
    if (event.target === this.search) {
      return false;
    }

    const visibleItems = this.getNavigableItems();
    const item = this.findTypeaheadMatch(event.key, visibleItems);

    if (!item) {
      return false;
    }

    const itemIndex = visibleItems.findIndex((visibleItem) => visibleItem === item);
    this.setCurrentItemByIndex(itemIndex, visibleItems);
    this.selectItem(item, { close: false, focusTrigger: false });
    return true;
  }

  getPlacementForKey(key) {
    if (key === "ArrowUp") {
      return "top-start";
    }

    return this.placement;
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
    const selectedValue = this.hiddenInput?.value;
    const selectedIndex = items.findIndex(
      (item) => item.dataset.value === selectedValue,
    );

    return selectedIndex >= 0 ? selectedIndex : (items.length > 0 ? 0 : -1);
  }

  setCurrentItemByIndex(index, items = this.getNavigableItems()) {
    const itemCount = items.length;

    if (itemCount === 0 || index < 0 || index >= itemCount) {
      this.currentIndex = -1;
      this.clearActiveItems();
      this.setActiveDescendant(null);
      return null;
    }

    items.forEach((item, itemIndex) => {
      item.setAttribute("tabindex", itemIndex === index ? "0" : "-1");
      item.dataset.active = String(itemIndex === index);

      if (itemIndex === index) {
        if (this.focusSelected) {
          this.focusElement(item);
        }
        this.scrollItemIntoView(item);
      }
    });

    this.currentIndex = index;
    this.setActiveDescendant(items[index]);
    return items[index];
  }

  syncValueFromDataset() {
    const serverValue = this.el.dataset.value;

    if (!this.hiddenInput) {
      return;
    }

    if (serverValue !== undefined && this.hiddenInput.value !== serverValue) {
      const serverItem = Array.from(this.items).find(
        (item) => item.dataset.value === serverValue,
      );

      if (serverItem) {
        this.selectItem(serverItem, { close: false, focusTrigger: false });
      } else {
        this.hiddenInput.value = serverValue;
        this.updatePlaceholder();
      }
    }
  }

  ensureOptionMetadata() {
    this.items.forEach((item, index) => {
      if (!item.id) {
        item.id = `${this.el.id || "pui-select"}-option-${index}`;
      }

      if (!item.dataset.label) {
        item.dataset.label = item.textContent.trim();
      }

      item.setAttribute("tabindex", "-1");
    });
  }

  selectDefaultValue() {
    const defaultValue = this.el.dataset.value;

    if (!defaultValue) {
      return;
    }

    const defaultItem = Array.from(this.items).find(
      (item) => item.dataset.value === defaultValue,
    );

    if (defaultItem) {
      this.selectItem(defaultItem, { close: false, focusTrigger: false });
    }
  }

  selectItem(itemEl, options = {}) {
    const { close = true, focusTrigger = true } = options;

    if (this.hiddenInput) {
      const newValue = itemEl.dataset.value;
      if (newValue && this.hiddenInput.value !== newValue) {
        this.hiddenInput.value = newValue;
        this.hiddenInput.dispatchEvent(new Event("change", { bubbles: true }));
      }
    }

    this.setSelectedItem(itemEl);
    this.updatePlaceholder();

    if (close) {
      this.closePopover();
    } else if (focusTrigger) {
      this.focusElement(this.trigger);
    }
  }

  setSelectedItem(selectedItem) {
    this.items.forEach((item) => {
      const isSelected = item === selectedItem;
      item.setAttribute("aria-selected", String(isSelected));
      item.setAttribute("tabindex", isSelected ? "0" : "-1");
    });

    const visibleItems = this.getNavigableItems();
    this.currentIndex = visibleItems.findIndex((item) => item === selectedItem);
    this.setActiveDescendant(selectedItem);
  }

  clearActiveItems() {
    this.items.forEach((item) => {
      delete item.dataset.active;
    });
  }

  updatePlaceholder() {
    const selectedItem = Array.from(this.items).find(
      (item) => item.dataset.value === this.hiddenInput?.value,
    );

    if (this.label) {
      this.label.textContent = selectedItem ? selectedItem.textContent : "";
    }
  }

  setActiveDescendant(item) {
    const activeId = item?.id;

    if (activeId) {
      this.trigger?.setAttribute("aria-activedescendant", activeId);
      this.search?.setAttribute("aria-activedescendant", activeId);
      return;
    }

    this.trigger?.removeAttribute("aria-activedescendant");
    this.search?.removeAttribute("aria-activedescendant");
  }

  clearSearch() {
    if (this.search) {
      this.search.value = "";
    }

    this.items.forEach((item) => {
      item.removeAttribute("aria-hidden");
    });

    this.resetTypeahead();
  }

  openPopover(options = {}) {
    this.activePlacement = options.placement || this.placement;
    this.trigger?.setAttribute("aria-expanded", "true");
    this.popup?.setAttribute("aria-hidden", "false");

    this.expanded = true;
    const visibleItems = this.getNavigableItems();
    this.currentIndex = this.getInitialNavigationIndex(visibleItems);
    this.setCurrentItemByIndex(this.currentIndex, visibleItems);

    if (this.search) {
      this.search.setAttribute("aria-expanded", "true");
      this.search.addEventListener("input", this.#searchInputHandler);
      this.focusElement(this.search);
    } else {
      this.focusElement(this.popup);
    }

    this.listenOutside();
    this.refreshFloatingUI();
  }

  closePopover() {
    this.trigger?.setAttribute("aria-expanded", "false");
    this.popup?.setAttribute("aria-hidden", "true");
    this.search?.setAttribute("aria-expanded", "false");
    this.search?.removeEventListener("input", this.#searchInputHandler);

    this.expanded = false;
    this.currentIndex = -1;
    this.activePlacement = this.placement;
    this.clearActiveItems();

    if (this.search) {
      this.clearSearch();
    }

    this.setActiveDescendant(
      Array.from(this.items).find(
        (item) => item.dataset.value === this.hiddenInput?.value,
      ),
    );

    if (
      this.popup?.contains(document.activeElement) ||
      this.trigger?.contains(document.activeElement)
    ) {
      this.focusElement(this.trigger);
    }

    this.removeOutsideListener();
  }

  initFloatingUI() {
    if (this.#clearFloating) {
      this.#clearFloating();
    }

    if (!this.trigger || !this.popup) {
      return;
    }

    this.#clearFloating = autoUpdate(this.trigger, this.popup, () => {
      this.refreshFloatingUI();
    });
  }

  refreshFloatingUI() {
    if (!this.trigger || !this.popup) {
      return;
    }

    const popup = this.popup;
    const expandPopover = this.expandPopover;
    computePosition(this.trigger, this.popup, {
      placement: this.activePlacement,
      strategy: this.strategy,
      middleware: [
        offset(8),
        flip(),
        shift(),
        size({
          apply({ rects }) {
            if (expandPopover) {
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

  listenOutside() {
    document.addEventListener("click", this.#outsideListener);
  }

  removeOutsideListener() {
    document.removeEventListener("click", this.#outsideListener);
  }

  findTypeaheadMatch(key, items = Array.from(this.items)) {
    const normalizedKey = key.toLowerCase();
    const navigableItems = items.filter(
      (item) =>
        item.getAttribute("aria-hidden") !== "true" &&
        item.getAttribute("aria-disabled") !== "true",
    );

    if (navigableItems.length === 0) {
      return null;
    }

    this.#typeaheadBuffer = `${this.#typeaheadBuffer}${normalizedKey}`;
    this.resetTypeaheadTimer();

    const currentValue = this.hiddenInput?.value;
    const startIndex = navigableItems.findIndex(
      (item) => item.dataset.value === currentValue,
    );
    const orderedItems = [
      ...navigableItems.slice(startIndex + 1),
      ...navigableItems.slice(0, startIndex + 1),
    ];

    return (
      orderedItems.find((item) =>
        item.dataset.label.toLowerCase().startsWith(this.#typeaheadBuffer),
      ) ||
      orderedItems.find((item) =>
        item.dataset.label.toLowerCase().startsWith(normalizedKey),
      ) ||
      null
    );
  }

  resetTypeaheadTimer() {
    window.clearTimeout(this.#typeaheadTimeout);
    this.#typeaheadTimeout = window.setTimeout(() => {
      this.resetTypeahead();
    }, 700);
  }

  resetTypeahead() {
    this.#typeaheadBuffer = "";
    window.clearTimeout(this.#typeaheadTimeout);
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
    if (!element || typeof element.focus !== "function") {
      return;
    }

    try {
      element.focus({ preventScroll: true });
    } catch {
      element.focus();
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
