<div class="statusbar-container">
  <div class="status-left">
    <div class="item">
      <span class="codicon codicon-remote"></span>
    </div>
    <div class="item">main*</div>
    <div class="item">0 errors, 0 warnings</div>
  </div>
  <div class="status-right">
    <div class="item">Spaces: 2</div>
    <div class="item">UTF-8</div>
    <div class="item">Svelte</div>
    <div class="item">
      <span class="codicon codicon-bell"></span>
    </div>
  </div>
</div>

<style>
  .statusbar-container {
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: space-between;
    background-color: var(--vscode-statusBar-background);
    color: var(--vscode-statusBar-foreground);
    font-size: 11px;
    padding: 0 8px;
    user-select: none;
  }

  .status-left, .status-right { display: flex; align-items: center; gap: 12px; height: 100%; }
  
  .item {
    height: 100%;
    display: flex;
    align-items: center;
    padding: 0 4px;
    cursor: pointer;
  }

  .item:hover { background-color: rgba(255, 255, 255, 0.1); }
</style>
