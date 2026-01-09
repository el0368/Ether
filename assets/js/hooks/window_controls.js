// WindowControls hook for Tauri window management
// Uses synchronous import with try-catch for browser compatibility

import { getCurrentWindow } from "@tauri-apps/api/window";

const WindowControls = {
  mounted() {
    // Check if Tauri API is available
    let tauriWindow;
    try {
      tauriWindow = getCurrentWindow();
    } catch (e) {
      console.log("WindowControls: Not in Tauri environment");
      return;
    }

    if (!tauriWindow) {
      console.log("WindowControls: No Tauri window available");
      return;
    }
    
    const updateMaximizeIcon = async () => {
      try {
        const isMaximized = await tauriWindow.isMaximized();
        const maximizeIcon = this.el.querySelector('.maximize-icon');
        const restoreIcon = this.el.querySelector('.restore-icon');
        
        if (maximizeIcon && restoreIcon) {
          if (isMaximized) {
            maximizeIcon.classList.add('hidden');
            restoreIcon.classList.remove('hidden');
            const btn = this.el.querySelector('[data-window-action="maximize"]');
            if (btn) btn.title = "Restore";
          } else {
            maximizeIcon.classList.remove('hidden');
            restoreIcon.classList.add('hidden');
            const btn = this.el.querySelector('[data-window-action="maximize"]');
            if (btn) btn.title = "Maximize";
          }
        }
      } catch (e) {
        console.warn("WindowControls: Error updating icon", e);
      }
    };

    updateMaximizeIcon();
    
    // Listen for resize to update icon
    window.addEventListener('resize', updateMaximizeIcon);
    
    // Also listen to Tauri event
    tauriWindow.listen('tauri://resize', updateMaximizeIcon);
    
    this.el.addEventListener("click", async e => {
      const target = e.target.closest('[data-window-action]');
      if (!target) return;
      
      const action = target.dataset.windowAction;
      try {
        if (action === "close") await tauriWindow.close();
        if (action === "minimize") await tauriWindow.minimize();
        if (action === "maximize") {
          const isMaximized = await tauriWindow.isMaximized();
          if (isMaximized) {
            await tauriWindow.unmaximize();
          } else {
            await tauriWindow.maximize();
          }
          setTimeout(updateMaximizeIcon, 100); 
        }
      } catch (e) {
        console.warn("WindowControls: Error handling action", action, e);
      }
    });
  }
};

export default WindowControls;
