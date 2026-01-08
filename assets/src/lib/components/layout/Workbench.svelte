<script>
  import { layout } from '../../state/layout.svelte';
  import Sash from '../ui/Sash.svelte';

  let { 
    titlebar,
    activitybar,
    sidebar,
    statusbar,
    panel,
    children 
  } = $props();
</script>

<div 
  class="workbench-container" 
  style="--sidebar-width: {layout.sidebarVisible ? layout.sidebarWidth : 0}px; --panel-height: {layout.panelVisible ? layout.panelHeight : 0}px;"
  class:sidebar-hidden={!layout.sidebarVisible}
  class:panel-hidden={!layout.panelVisible}
>
  <div class="part-titlebar">
    {@render titlebar?.()}
  </div>
  
  <div class="part-activitybar">
    {@render activitybar?.()}
  </div>

  <div class="part-sidebar">
    {@render sidebar?.()}
    {#if layout.sidebarVisible}
      <Sash orientation="vertical" onResize={(dx) => layout.resizeSidebar(dx)} />
    {/if}
  </div>

  <main class="part-editor">
    {@render children?.()}
  </main>

  <div class="part-panel">
    {#if layout.panelVisible}
      <Sash orientation="horizontal" onResize={(_, dy) => layout.resizePanel(dy)} />
    {/if}
    {@render panel?.()}
  </div>

  <div class="part-statusbar">
    {@render statusbar?.()}
  </div>
</div>

<style>
  .workbench-container {
    display: grid;
    height: 100vh;
    width: 100vw;
    overflow: hidden;
    grid-template-areas:
      "title title title"
      "activity sidebar main"
      "activity sidebar panel"
      "status status status";
    grid-template-rows: var(--vscode-titleBar-height) 1fr auto var(--vscode-statusBar-height);
    grid-template-columns: var(--vscode-activityBar-width) var(--sidebar-width) 1fr;
    background-color: var(--vscode-editor-background);
    color: var(--vscode-foreground);
    font-family: var(--vscode-font-family);
  }

  .part-titlebar { grid-area: title; z-index: 10; }
  .part-activitybar { grid-area: activity; z-index: 5; }
  .part-sidebar { grid-area: sidebar; position: relative; z-index: 4; }
  .part-editor { grid-area: main; position: relative; overflow: hidden; z-index: 1; }
  .part-panel { grid-area: panel; position: relative; z-index: 3; }
  .part-statusbar { grid-area: status; z-index: 10; }

  .sidebar-hidden .part-sidebar { display: none; }
  .panel-hidden .part-panel { display: none; }
</style>
