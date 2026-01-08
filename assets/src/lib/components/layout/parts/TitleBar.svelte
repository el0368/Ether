<div class="titlebar-container">
  <div class="titlebar-left">
    <img src="/favicon.svg" alt="Ether" class="logo" />
    <span class="menu-hint">File</span>
    <span class="menu-hint">Edit</span>
    <span class="menu-hint">Selection</span>
  </div>
  <div class="titlebar-center">
    <span>Ether - Project Explorer</span>
  </div>
  <div class="titlebar-right">
    <!-- Window Controls (Tauri will handle or we simulate) -->
  </div>
</div>

<style>
  .titlebar-container {
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: space-between;
    background-color: var(--vscode-titleBar-activeBackground);
    font-size: 12px;
    padding: 0 8px;
    user-select: none;
    border-bottom: 1px solid rgba(255, 255, 255, 0.05);
  }

  .titlebar-left { display: flex; align-items: center; gap: 12px; }
  .logo { width: 16px; height: 16px; filter: grayscale(1); opacity: 0.8; }
  .menu-hint { opacity: 0.8; color: var(--vscode-foreground); cursor: pointer; }
  .menu-hint:hover { opacity: 1; }
  
  .titlebar-center { flex: 1; text-align: center; opacity: 0.6; pointer-events: none; }
</style>
