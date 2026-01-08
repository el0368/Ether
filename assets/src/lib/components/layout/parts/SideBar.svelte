<div class="sidebar-container">
  <div class="sidebar-header">
    <span>EXPLORER</span>
    <div class="actions">...</div>
  </div>
  <div class="sidebar-content">
    <!-- Tree View will be injected here in Step 3.3 -->
    <div class="placeholder">ETHER PROJECT</div>
  </div>
</div>

<style>
  .sidebar-container {
    height: 100%;
    width: 100%;
    background-color: var(--vscode-sideBar-background);
    border-right: 1px solid rgba(255, 255, 255, 0.05);
    display: flex;
    flex-direction: column;
  }

  .sidebar-header {
    height: 35px;
    padding: 0 20px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    font-size: 11px;
    font-weight: bold;
    color: var(--vscode-sideBar-foreground);
    opacity: 0.8;
  }

  .sidebar-content {
    flex: 1;
    overflow-y: auto;
    padding: 10px;
    font-size: 12px;
  }

  .placeholder {
    opacity: 0.3;
    font-style: italic;
    text-align: center;
    margin-top: 20px;
  }
</style>
