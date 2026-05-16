const STORAGE_KEY = "pui-sidebar-collapsed";

const Sidebar = {
  mounted() {
    if (this.el.dataset.shell) {
      this.initShell();
    } else if (this.el.dataset.target) {
      this.initMenuItem();
    } else {
      this.initShell();
    }
  },

  updated() {
    if (this.el.dataset.shell) {
      this.syncShell(this.collapsed ?? this.shell?.dataset.collapsed === "true");
    } else if (this.el.dataset.target) {
      this.syncMenuItem(this.el.dataset.expanded !== "false");
    } else {
      this.syncShell(this.collapsed ?? this.el.dataset.collapsed === "true");
    }
  },

  destroyed() {
    if (this.trigger && this.onClick) {
      this.trigger.removeEventListener("click", this.onClick);
    }

    if (this.toggleButton && this.onToggleClick) {
      this.toggleButton.removeEventListener("click", this.onToggleClick);
    }

  },

  initMenuItem() {
    this.targetId = this.el.dataset.target;
    this.trigger = this.el.querySelector("button");
    this.chevron = this.el.querySelector(".sidebar-collapsible-chevron");
    this.onClick = () => this.toggleMenuItem();
    this.syncMenuItem(this.el.dataset.expanded !== "false");

    if (this.trigger) this.trigger.addEventListener("click", this.onClick);
  },

  initShell() {
    this.shell = this.el.dataset.shell ? document.getElementById(this.el.dataset.shell) : this.el;
    this.toggleButton = this.shell
      ? document.getElementById(`${this.shell.id}-sidebar-collapse-toggle`)
      : null;
    this.onToggleClick = () => this.toggleShell();

    if (this.shell) {
      this.js().ignoreAttributes(this.shell, ["data-collapsed"]);
    }

    const stored = this.readStoredState();
    const initial = stored ?? this.readShellState();
    this.syncShell(initial);

    if (this.toggleButton) {
      this.toggleButton.addEventListener("click", this.onToggleClick);
    }
  },

  toggleMenuItem() {
    const expanded = this.el.dataset.expanded !== "false";
    this.syncMenuItem(!expanded);
  },

  toggleShell() {
    const collapsed = this.shell?.dataset.collapsed === "true";

    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        this.syncShell(!collapsed, { emit: true });
      });
    });
  },

  syncMenuItem(expanded) {
    const value = expanded ? "true" : "false";
    const target = this.targetId ? document.getElementById(this.targetId) : null;

    this.el.dataset.expanded = value;
    if (this.trigger) this.trigger.setAttribute("aria-expanded", value);
    if (this.chevron) this.chevron.dataset.expanded = value;

    if (target) {
      target.dataset.expanded = value;
      target.setAttribute("aria-hidden", expanded ? "false" : "true");
    }
  },

  syncShell(collapsed, options = {}) {
    if (!this.shell) return;

    this.collapsed = collapsed;
    this.shell.dataset.collapsed = collapsed ? "true" : "false";
    this.storeState(collapsed);

    if (options.emit) {
      this.shell.dispatchEvent(
        new CustomEvent("pui:sidebar-collapsed", {
          bubbles: true,
          detail: { collapsed },
        })
      );
    }
  },

  readShellState() {
    if (!this.shell) return false;

    return this.shell.dataset.collapsed === "true";
  },

  readStoredState() {
    try {
      const value = sessionStorage.getItem(STORAGE_KEY);
      return value === "true" ? true : value === "false" ? false : null;
    } catch {
      return null;
    }
  },

  storeState(collapsed) {
    try {
      sessionStorage.setItem(STORAGE_KEY, String(collapsed));
    } catch {
      // ignore
    }
  },
};

export default Sidebar;
