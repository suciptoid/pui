const SidebarMenuItemCollapse = {
  mounted() {
    this.targetId = this.el.dataset.target;
    this.trigger = this.el.querySelector("button");
    this.chevron = this.el.querySelector(".sidebar-collapsible-chevron");
    this.onClick = () => this.toggle();
    this.sync(this.el.dataset.expanded !== "false");

    if (this.trigger) this.trigger.addEventListener("click", this.onClick);
  },

  updated() {
    this.sync(this.el.dataset.expanded !== "false");
  },

  destroyed() {
    if (this.trigger && this.onClick) {
      this.trigger.removeEventListener("click", this.onClick);
    }
  },

  toggle() {
    const expanded = this.el.dataset.expanded !== "false";
    this.sync(!expanded);
  },

  sync(expanded) {
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
};

export default SidebarMenuItemCollapse;
