import { getCurrentWindow } from "@tauri-apps/api/window";

const WindowControls = {
  mounted() {
    const window = getCurrentWindow();
    
    const updateMaximizeIcon = async () => {
      const isMaximized = await window.isMaximized();
      const maximizeIcon = this.el.querySelector('.maximize-icon');
      const restoreIcon = this.el.querySelector('.restore-icon');
      
      if (maximizeIcon && restoreIcon) {
        if (isMaximized) {
          maximizeIcon.classList.add('hidden');
          restoreIcon.classList.remove('hidden');
          this.el.querySelector('[data-window-action="maximize"]').title = "Restore";
        } else {
          maximizeIcon.classList.remove('hidden');
          restoreIcon.classList.add('hidden');
          this.el.querySelector('[data-window-action="maximize"]').title = "Maximize";
        }
      }
    };

    updateMaximizeIcon();
    
    // Listen for resize to update icon (e.g. OS snap)
    // Using standard window resize event which is most reliable
    window.addEventListener('resize', updateMaximizeIcon);
    
    // Also listen to Tauri event as backup
    window.listen('tauri://resize', updateMaximizeIcon);
    
    this.el.addEventListener("click", async e => {
      const target = e.target.closest('[data-window-action]');
      if (!target) return;
      
      const action = target.dataset.windowAction;
      if (action === "close") window.close();
      if (action === "minimize") window.minimize();
      if (action === "maximize") {
        const isMaximized = await window.isMaximized();
        if (isMaximized) {
          await window.unmaximize();
        } else {
          await window.maximize();
        }
        setTimeout(updateMaximizeIcon, 100); 
      }
    });
  }
};

export default WindowControls;
