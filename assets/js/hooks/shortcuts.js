export const GlobalShortcuts = {
  mounted() {
    this.handleKeydown = (e) => {
      // Ctrl+P or Cmd+P (Mac)
      if ((e.ctrlKey || e.metaKey) && e.key === 'p') {
        e.preventDefault(); // Prevent Print dialog
        this.pushEvent("open_quick_pick", { mode: "files" });
      }
      
      // Ctrl+Shift+P or Cmd+Shift+P (Mac)
      if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key === 'P') {
        e.preventDefault();
        this.pushEvent("open_quick_pick", { mode: "commands" });
      }

      // Ctrl+B (Toggle Sidebar)
      if ((e.ctrlKey || e.metaKey) && e.key === 'b') {
        e.preventDefault();
        this.pushEvent("toggle_sidebar", {});
      }
    };

    window.addEventListener("keydown", this.handleKeydown);
  },

  destroyed() {
    window.removeEventListener("keydown", this.handleKeydown);
  }
};
