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
      this.syncShell(this.shell?.dataset.collapsed === "true");
    } else if (this.el.dataset.target) {
      this.syncMenuItem(this.el.dataset.expanded !== "false");
    } else {
      this.syncShell(this.el.dataset.collapsed === "true");
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
    this.syncShell(this.shell?.dataset.collapsed === "true");

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

    this.shell.dataset.collapsed = collapsed ? "true" : "false";

    if (options.emit) {
      this.shell.dispatchEvent(
        new CustomEvent("pui:sidebar-collapsed", {
          bubbles: true,
          detail: { collapsed },
        })
      );
    }
  },
};

export default Sidebar;
