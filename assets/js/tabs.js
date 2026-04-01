import { ViewHook } from "phoenix_live_view";

export default class Tabs extends ViewHook {
  #clickHandler;
  #keyDownHandler;
  #focusHandler;

  mounted() {
    this.cacheElements();
    this.bindEventListeners();
    this.syncFromRootDataset();
  }

  updated() {
    const previousTabs = this.tabs;
    this.cacheElements();
    this.rebindEventListeners(previousTabs);
    this.syncFromRootDataset();
  }

  destroyed() {
    this.unbindEventListeners(this.tabs);
  }

  cacheElements() {
    this.tabs = Array.from(this.el.querySelectorAll("[role='tab']"));
    this.panels = Array.from(this.el.querySelectorAll("[role='tabpanel']"));
    this.orientation = this.el.dataset.orientation || "horizontal";
    this.activationMode = this.el.dataset.activationMode || "automatic";
    this.clientControlled = this.el.dataset.clientControlled !== "false";
  }

  bindEventListeners() {
    this.#clickHandler = this.handleClick.bind(this);
    this.#keyDownHandler = this.handleKeyDown.bind(this);
    this.#focusHandler = this.handleFocus.bind(this);

    this.tabs.forEach((tab) => {
      tab.addEventListener("click", this.#clickHandler);
      tab.addEventListener("keydown", this.#keyDownHandler);
      tab.addEventListener("focus", this.#focusHandler);
    });
  }

  unbindEventListeners(tabs) {
    tabs?.forEach((tab) => {
      tab.removeEventListener("click", this.#clickHandler);
      tab.removeEventListener("keydown", this.#keyDownHandler);
      tab.removeEventListener("focus", this.#focusHandler);
    });
  }

  rebindEventListeners(previousTabs) {
    if (
      previousTabs &&
      previousTabs.length === this.tabs.length &&
      previousTabs.every((tab, index) => tab === this.tabs[index])
    ) {
      return;
    }

    this.unbindEventListeners(previousTabs);
    this.bindEventListeners();
  }

  handleClick(event) {
    const tab = event.currentTarget;

    if (!this.clientControlled || this.isDisabled(tab)) {
      return;
    }

    this.activateTab(tab, { focus: false });
  }

  handleFocus(event) {
    if (!this.clientControlled || this.activationMode !== "automatic") {
      return;
    }

    const tab = event.currentTarget;

    if (this.isDisabled(tab)) {
      return;
    }

    this.activateTab(tab, { focus: false });
  }

  handleKeyDown(event) {
    const currentTab = event.currentTarget;
    const enabledTabs = this.enabledTabs();

    if (enabledTabs.length === 0) {
      return;
    }

    switch (event.key) {
      case "ArrowRight":
        if (this.orientation !== "horizontal") return;
        event.preventDefault();
        this.moveFocus(currentTab, enabledTabs, 1);
        break;
      case "ArrowLeft":
        if (this.orientation !== "horizontal") return;
        event.preventDefault();
        this.moveFocus(currentTab, enabledTabs, -1);
        break;
      case "ArrowDown":
        if (this.orientation !== "vertical") return;
        event.preventDefault();
        this.moveFocus(currentTab, enabledTabs, 1);
        break;
      case "ArrowUp":
        if (this.orientation !== "vertical") return;
        event.preventDefault();
        this.moveFocus(currentTab, enabledTabs, -1);
        break;
      case "Home":
        event.preventDefault();
        this.focusTab(enabledTabs[0]);
        break;
      case "End":
        event.preventDefault();
        this.focusTab(enabledTabs[enabledTabs.length - 1]);
        break;
      case "Enter":
      case " ":
        if (!this.clientControlled) return;
        event.preventDefault();
        this.activateTab(currentTab);
        break;
    }
  }

  moveFocus(currentTab, enabledTabs, delta) {
    const currentIndex = enabledTabs.findIndex((tab) => tab === currentTab);
    const nextIndex = (currentIndex + delta + enabledTabs.length) % enabledTabs.length;
    this.focusTab(enabledTabs[nextIndex]);
  }

  focusTab(tab) {
    if (!tab) {
      return;
    }

    tab.focus();

    if (this.clientControlled && this.activationMode === "automatic") {
      this.activateTab(tab, { focus: false });
    }
  }

  activateTab(tab, options = {}) {
    const value = tab?.dataset.value;

    if (!value) {
      return;
    }

    this.el.dataset.value = value;

    this.tabs.forEach((item) => {
      const selected = item === tab;
      item.setAttribute("aria-selected", String(selected));
      item.setAttribute("data-state", selected ? "active" : "inactive");
      item.setAttribute("tabindex", selected ? "0" : "-1");
    });

    this.panels.forEach((panel) => {
      const selected = panel.dataset.value === value;
      panel.setAttribute("data-state", selected ? "active" : "inactive");
      panel.hidden = !selected;
    });

    if (options.focus !== false) {
      tab.focus();
    }
  }

  syncFromRootDataset() {
    const value =
      this.el.dataset.value ||
      this.el.dataset.defaultValue ||
      this.enabledTabs()[0]?.dataset.value;

    const activeTab = this.tabs.find((tab) => tab.dataset.value === value) || this.enabledTabs()[0];

    if (activeTab) {
      this.activateTab(activeTab, { focus: false });
      return;
    }

    this.tabs.forEach((tab) => {
      tab.setAttribute("aria-selected", "false");
      tab.setAttribute("data-state", "inactive");
      tab.setAttribute("tabindex", "-1");
    });

    this.panels.forEach((panel) => {
      panel.setAttribute("data-state", "inactive");
      panel.hidden = true;
    });
  }

  enabledTabs() {
    return this.tabs.filter((tab) => !this.isDisabled(tab));
  }

  isDisabled(tab) {
    return tab?.disabled || tab?.dataset.disabled === "true";
  }
}
