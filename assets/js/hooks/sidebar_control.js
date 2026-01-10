const SidebarControl = {
  mounted() {
    this.debounceTimer = null;
    console.log("SidebarControl: Mounted");
    
    // Initial Sync
    this.syncUI();

    this.el.addEventListener("contextmenu", (e) => {
      e.preventDefault();
      const icon = e.target.closest(".activity-icon");
      if (!icon) return;

      const panelName = icon.dataset.panel;
      if (!panelName) return;

      console.log("SidebarControl: ContextMenu", panelName);
      this.pushEvent("show_context_menu", { 
        panel: panelName, 
        x: e.clientX, 
        y: e.clientY 
      });
    });

    this.el.addEventListener("click", (e) => {
      const icon = e.target.closest(".activity-icon");
      if (!icon) return;

      const panelName = icon.dataset.panel;
      if (!panelName) return;

      // The server will handle the state update via set_sidebar
      // But we can do an optimistic transition here if needed
      // For now, let's let LiveView handle the toggling since we are refactoring to data-driven
    });
  },

  updated() {
    console.log("SidebarControl: Updated from Server");
    // If server re-renders, ensure we stay in sync
    this.syncUI();
  },

  syncUI() {
    const activePanel = this.el.dataset.activeSidebar;
    const isVisible = this.el.dataset.sidebarVisible === "true";
    console.log("SidebarControl: SyncUI", { activePanel, isVisible });
    this.updateLayout(activePanel, isVisible);
  },

  updateLayout(activePanel, isVisible) {
    // 1. Update Icons
    const icons = this.el.querySelectorAll(".activity-icon");
    icons.forEach(icon => {
      const isTarget = icon.dataset.panel === activePanel;
      if (isTarget && isVisible) {
        icon.classList.remove("text-[#858585]", "border-transparent");
        icon.classList.add("text-white", "opacity-100", "border-white", "active");
      } else {
        icon.classList.add("text-[#858585]", "border-transparent");
        icon.classList.remove("text-white", "opacity-100", "border-white", "active");
      }
    });

    // 2. Update Sidebar Container
    const container = document.getElementById("sidebar-container");
    if (container) {
      if (isVisible) {
        container.classList.remove("w-0", "min-w-0", "opacity-0", "border-none");
        container.classList.add("w-[var(--vscode-sidebar-width)]", "min-w-[var(--vscode-sidebar-width)]", "opacity-100");
      } else {
        container.classList.add("w-0", "min-w-0", "opacity-0", "border-none");
        container.classList.remove("w-[var(--vscode-sidebar-width)]", "min-w-[var(--vscode-sidebar-width)]", "opacity-100");
      }
    }

    // 3. Update Panels (Off-screen rendering)
    const allPanels = document.querySelectorAll(".sidebar-panel");
    allPanels.forEach(panel => {
      const panelName = panel.id.replace("sidebar-panel-", "");
      if (panelName === activePanel && isVisible) {
        panel.classList.remove("invisible", "-translate-x-full");
        panel.classList.add("translate-x-0");
      } else {
        panel.classList.add("invisible", "-translate-x-full");
        panel.classList.remove("translate-x-0");
      }
    });
  }
};

export default SidebarControl;
