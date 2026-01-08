<div class="panel-container">
  <div class="panel-header">
    <div class="tabs">
      <div class="tab">TERMINAL</div>
      <div class="tab active">OUTPUT</div>
      <div class="tab">DEBUG CONSOLE</div>
      <div class="tab">PROBLEMS</div>
    </div>
  </div>
  <div class="panel-content">
    <div class="console">
      [Ether] Initializing Svelte Shell...
      [Ether] CSS Design Tokens injected.
      [Ether] Grid Layout ready.
    </div>
  </div>
</div>

<style>
  .panel-container {
    height: var(--vscode-panel-height);
    background-color: var(--vscode-editor-background);
    border-top: 1px solid rgba(255, 255, 255, 0.1);
    display: flex;
    flex-direction: column;
  }

  .panel-header {
    height: 35px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.05);
    padding: 0 20px;
    display: flex;
    align-items: center;
  }

  .tabs { display: flex; gap: 20px; height: 100%; }
  .tab {
    height: 100%;
    display: flex;
    align-items: center;
    font-size: 11px;
    opacity: 0.6;
    cursor: pointer;
    border-bottom: 1px solid transparent;
  }

  .tab:hover { opacity: 1; }
  .tab.active { opacity: 1; border-bottom-color: var(--vscode-foreground); }

  .panel-content {
    flex: 1;
    padding: 10px 20px;
    font-family: var(--vscode-editor-font-family);
    font-size: 12px;
    opacity: 0.8;
  }
</style>
