<script>
  // Svelte 5 Runes Mode
  let { socket } = $props();
  import { NifDecoder } from "./lib/nif_decoder";

  // Components
  import TitleBar from "./components/TitleBar.svelte";
  import ActivityBar from "./components/ActivityBar.svelte";
  import SideBar from "./components/SideBar.svelte";
  import EditorLayout from "./components/EditorLayout.svelte";
  import StatusBar from "./components/StatusBar.svelte";
  import Terminal from "./components/Terminal.svelte";
  import RefactorModal from "./components/RefactorModal.svelte";
  import QuickPicker from "./lib/components/ui/QuickPicker.svelte";
  import WelcomePage from "./components/WelcomePage.svelte";
  import DropdownMenu from "./components/DropdownMenu.svelte";
  import Boundary from "./components/Boundary.svelte";
  
  // Decoupled State
  import { ui } from "./lib/state/ui.svelte";
  import { editor } from "./lib/state/editor.svelte";
  import { menuState } from "./lib/state/menu.svelte";
  import { comms } from "./lib/state/comms.svelte";
  import { explorer } from "./lib/state/explorer.svelte";
  import { layout } from "./lib/state/layout.svelte";
  
  // No longer needed here, orchestrated by explorer.svelte
  // import * as TauriFS from "./lib/tauri_fs";

  import { 
    FilePlus, FolderOpen, Save, Settings, 
    Undo, Redo, Scissors, Copy, Clipboard,
    Search, PanelLeft, Terminal as TerminalIcon, Monitor
  } from "lucide-svelte";

  // Reactive connectivity state (kept here for visual pulse)
  let nifPulse = $state(false);

  // Modal State
  let showRefactor = $state(false);
  let recentFiles = $state([]);
  let documentSymbols = $state([]);

  function triggerPulse() {
    nifPulse = true;
    setTimeout(() => (nifPulse = false), 500);
  }

  import { onMount } from 'svelte';

  // Socket Connection Orchestration
  onMount(() => {
    console.log("App Mounted. Socket:", socket);
    let batchTimer = null;
    let ch = null;

    // 🔄 PERSISTENCE: Restore previous folder
    console.log("Checking for persistence...");
    const savedPath = explorer.loadState();
    if (savedPath && savedPath !== "null" && savedPath !== "undefined") {
       console.log("Restoring folder:", savedPath);
       explorer.loadFolder(savedPath);
    } else {
       console.log("No persisted folder found.");
    }

    if (socket && !comms.channel) {
      console.log("Attempting to join channel...");
      
      ch = socket.channel("editor:lobby", {});
      ch.join()
        .receive("ok", (resp) => {
          console.log("Joined EditorChannel", resp);
          comms.setChannel(ch); // This won't trigger re-run of onMount
          triggerPulse();

          // UI Batching State
          batchTimer = setInterval(() => explorer.flushBatch(), 50);

          // Streaming Protocol & Delta Handlers
          ch.on("filetree:chunk", (payload) => {
            try {
              const newFiles = NifDecoder.decodeChunk(payload.chunk, ".");
              explorer.addChunk(newFiles);
            } catch (e) {
              console.error("Chunk Error:", e);
            }
          });

          ch.on("filetree:done", () => {
            explorer.flushBatch();
            ui.isLoading = false; 
            explorer.sort();

            const readme = explorer.fileTree.find(f => f.name.toLowerCase() === "readme.md");
            if (readme) openFile(readme);
          });

          ch.on("filetree:delta", (payload) => {
            explorer.applyDelta(payload);
          });

          // NO AUTO-LOAD: User must click "Open Folder" to load a project.
          ui.isLoading = false;
        })
        .receive("error", (resp) => console.error("Failed", resp));
    }

    // Cleanup function
    return () => {
      if (batchTimer) clearInterval(batchTimer);
      if (ch) comms.clearChannel();
    };
  });

  function handleExpand(file) {
    if (explorer.expandedPaths.has(file.path)) return;
    explorer.expandedPaths.add(file.path);
    if (comms.channel) {
      comms.channel.push("filetree:list_raw", { path: file.path });
    }
  }

  function openFile(file) {
    ui.showPalette = false;
    editor.openFile(file, comms.channel);
  }

  function splitEditor() {
    editor.splitEditor();
  }

  function toggleSidebar(section) {
    ui.toggleSidebar(section);
  }

  function handleRefactorSuccess(newCode) {
    editor.activeGroup.content = newCode;
  }

  function handleGlobalKeydown(e) {
    if (e.ctrlKey && e.key === "p") {
      e.preventDefault();
      ui.paletteMode = "files";
      if (comms.channel) {
        comms.channel.push("editor:recent", {}).receive("ok", (resp) => {
          recentFiles = resp.files || [];
        });
      }
      ui.showPalette = true;
    } else if (e.ctrlKey && e.shiftKey && e.key === "O") {
      e.preventDefault();
      ui.paletteMode = "symbols";
      if (comms.channel && editor.activeGroup.file) {
        comms.channel
          .push("lsp:symbols", { path: editor.activeGroup.file.path })
          .receive("ok", (resp) => {
            documentSymbols = resp.symbols || [];
          });
      }
      ui.showPalette = true;
    } else if (e.ctrlKey && e.shiftKey && e.key === "f") {
      e.preventDefault();
      ui.toggleSidebar("search");
    } else if (e.ctrlKey && e.key === "\\") {
      e.preventDefault();
      editor.splitEditor();
    }
  }


  const emptyMenu = [];

  import Workbench from "./lib/components/layout/Workbench.svelte";
</script>

<div
  class="app-container"
  onkeydown={handleGlobalKeydown}
  tabindex="-1"
  role="application"
>
  <Workbench>
    {#snippet titlebar()}
      <TitleBar>
        <DropdownMenu label="File" items={menuState.fileMenuItems} />
        <DropdownMenu label="Edit" items={menuState.editMenuItems} />
        <DropdownMenu label="Selection" items={menuState.selectionMenuItems} />
        <DropdownMenu label="View" items={menuState.viewMenuItems} />
        <DropdownMenu label="Go" items={emptyMenu} />
        <DropdownMenu label="Run" items={emptyMenu} />
        <DropdownMenu label="Terminal" items={emptyMenu} />
        <DropdownMenu label="Help" items={menuState.helpMenuItems} />
      </TitleBar>
    {/snippet}

    {#snippet activitybar()}
      <ActivityBar 
        activeSidebar={ui.activeSidebar} 
        sidebarVisible={layout.sidebarVisible} 
        onToggle={(section) => {
          if (ui.activeSidebar === section && layout.sidebarVisible) {
            layout.toggleSidebar();
          } else {
            ui.activeSidebar = section;
            layout.sidebarVisible = true;
          }
        }} 
      />
    {/snippet}

    {#snippet sidebar()}
      <Boundary name="SideBar">
        <SideBar
          activeSidebar={ui.activeSidebar}
          sidebarVisible={layout.sidebarVisible}
          fileTree={explorer.fileTree}
          activeFile={editor.activeGroup.file}
          isLoading={ui.isLoading}
          channel={comms.channel}
          onOpenFile={openFile}
          onExpand={handleExpand}
          onNewFile={() => editor.newUntitled()}
          onNewFolder={() => {}}
          onRefresh={() => {
            if (comms.channel) {
              ui.isLoading = true;
              explorer.clear();
              comms.channel.push("filetree:list_raw", { path: "." });
            }
          }}
          onMenuClick={() => {}}
          onOpenProjectFolder={() => explorer.openFolder(comms.channel)}
        />
      </Boundary>
    {/snippet}

    <div class="flex-1 flex flex-col min-w-0 h-full">
      <Boundary name="MainEditor">
        {#if editor.activeGroup.file}
          <EditorLayout
            bind:editorGroups={editor.groups}
            bind:activeGroupIndex={editor.activeIndex}
            channel={comms.channel}
            onSplit={splitEditor}
          />
        {:else}
          <WelcomePage 
            {recentFiles}
            onNewFile={() => editor.newUntitled()}
            onOpenFile={(file) => openFile(file)}
            onOpenFolder={() => explorer.openFolder(comms.channel)}
          />
        {/if}
      </Boundary>
    </div>

    {#snippet panel()}
      {#if layout.panelVisible}
        <Boundary name="Terminal">
          <Terminal 
            channel={comms.channel} 
            onClose={() => layout.togglePanel()}
          />
        </Boundary>
      {/if}
    {/snippet}

    {#snippet statusbar()}
      <StatusBar {nifPulse} activeFile={editor.activeGroup.file} />
    {/snippet}
  </Workbench>
</div>

<!-- Modals -->
<RefactorModal
  isOpen={showRefactor}
  code={editor.activeGroup.content}
  oldName="variable"
  channel={comms.channel}
  onClose={() => (showRefactor = false)}
  onSuccess={handleRefactorSuccess}
/>

<QuickPicker
  isOpen={ui.showPalette}
  items={explorer.fileTree}
  {recentFiles}
  symbols={documentSymbols}
  mode={ui.paletteMode}
  onSelect={(item) => {
    if (ui.paletteMode === "symbols" && item.line) {
      ui.showPalette = false;
      window.dispatchEvent(
        new CustomEvent("goto-line", { detail: { line: item.line } }),
      );
    } else {
      openFile(item);
    }
  }}
  onClose={() => (ui.showPalette = false)}
/>

<style>
  .app-container {
    display: flex;
    flex-direction: column;
    height: 100vh;
    width: 100vw;
  }
</style>
