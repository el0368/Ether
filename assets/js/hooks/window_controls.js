import { getCurrentWindow } from "@tauri-apps/api/window";

const WindowControls = {
  mounted() {
    const window = getCurrentWindow();
    
    this.el.addEventListener("click", e => {
      const action = e.target.dataset.windowAction;
      if (action === "close") window.close();
      if (action === "minimize") window.minimize();
      if (action === "maximize") window.toggleMaximize();
    });
  }
};

export default WindowControls;
