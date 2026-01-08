/* Layout State Rune for Ether */
import { explorer } from "./explorer.svelte";

class LayoutState {
  sidebarWidth = $state(260);
  panelHeight = $state(300);
  sidebarVisible = $state(true);
  panelVisible = $state(false);

  constructor() {
    this.load();
  }

  toggleSidebar() {
    this.sidebarVisible = !this.sidebarVisible;
    this.save();
  }

  togglePanel() {
    this.panelVisible = !this.panelVisible;
    this.save();
  }

  resizeSidebar(deltaX) {
    this.sidebarWidth = Math.max(170, Math.min(600, this.sidebarWidth + deltaX));
    this.save();
  }

  resizePanel(deltaY) {
    this.panelHeight = Math.max(77, Math.min(800, this.panelHeight - deltaY));
    this.save();
  }

  save() {
    localStorage.setItem('ether-layout', JSON.stringify({
      sidebarWidth: this.sidebarWidth,
      panelHeight: this.panelHeight,
      sidebarVisible: this.sidebarVisible,
      panelVisible: this.panelVisible
    }));
  }

  load() {
    const saved = localStorage.getItem('ether-layout');
    if (saved) {
      const data = JSON.parse(saved);
      this.sidebarWidth = data.sidebarWidth ?? 260;
      this.panelHeight = data.panelHeight ?? 300;
      this.sidebarVisible = data.sidebarVisible ?? true;
      this.panelVisible = data.panelVisible ?? false;
    }
  }
}

export const layout = new LayoutState();
