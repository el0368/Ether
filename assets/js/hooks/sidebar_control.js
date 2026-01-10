  mounted() {
    this.debounceTimer = null;
    
    // Initialize state from server (support page reload)
    const initialPanel = this.el.dataset.initialActive;
    if (initialPanel) {
      this.updateUI(initialPanel);
    }
    
    this.el.addEventListener("click", (e) => {
      const icon = e.target.closest(".activity-icon");
      if (!icon) return;

      const panelName = icon.dataset.panel;
      if (!panelName) return;

      // 1. Optimistic Visual Update (Instant)
      this.updateUI(panelName);

      // 2. Debounced Server Sync
      clearTimeout(this.debounceTimer);
      this.debounceTimer = setTimeout(() => {
        this.pushEvent("set_sidebar", { panel: panelName });
      }, 50); 
    });
  },

  updateUI(activePanel) {
    // 1. Update Icons (Child of this element)
    const icons = this.el.querySelectorAll(".activity-icon");
    icons.forEach(icon => {
      const isTarget = icon.dataset.panel === activePanel;
      if (isTarget) {
        icon.classList.remove("text-[#858585]", "border-transparent", "hover:text-white");
        icon.classList.add("text-white", "opacity-100", "border-white", "active");
      } else {
        icon.classList.add("text-[#858585]", "border-transparent", "hover:text-white");
        icon.classList.remove("text-white", "opacity-100", "border-white", "active");
      }
    });

    // 2. Update Panels (Global lookup)
    // We assume panel IDs follow convention: sidebar-panel-{name}
    const allPanels = document.querySelectorAll(".sidebar-panel");
    allPanels.forEach(panel => {
        // ID format: "sidebar-panel-files"
        const panelName = panel.id.replace("sidebar-panel-", "");
        
        if (panelName === activePanel) {
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
