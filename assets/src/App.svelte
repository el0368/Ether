<script>
  // Svelte 5 Runes Mode
  let { socket } = $props();
  import { NifDecoder } from "./lib/nif_decoder";
  import { applyDelta } from "./lib/delta_handler";

  // Initialize Theme Synchronously
  const savedTheme = localStorage.getItem("theme") || "dark";
  document.documentElement.setAttribute("data-theme", savedTheme);

  // Components
  import TitleBar from "./components/TitleBar.svelte";
  import ActivityBar from "./components/ActivityBar.svelte";
  import SideBar from "./components/SideBar.svelte";
  import EditorLayout from "./components/EditorLayout.svelte";
  import StatusBar from "./components/StatusBar.svelte";
  import Terminal from "./components/Terminal.svelte";
  import RefactorModal from "./components/RefactorModal.svelte";
  import CommandPalette from "./components/CommandPalette.svelte";

  // Reactive state
  let connected = $state(false);
  let fileTree = $state([]);
  let nifPulse = $state(false);
  let channel = $state(null);

  // Editor State
  let editorGroups = $state([{ file: null, content: "" }]);
  let activeGroupIndex = $state(0);
  let activeGroup = $derived(editorGroups[activeGroupIndex]);

  // Sidebar State
  let activeSidebar = $state("files");
  let sidebarVisible = $state(true);

  // Modal State
  let showRefactor = $state(false);
  let showPalette = $state(false);
  let paletteMode = $state("files");
  let recentFiles = $state([]);
  let documentSymbols = $state([]);

  function triggerPulse() {
    nifPulse = true;
    setTimeout(() => (nifPulse = false), 500);
  }

  // Socket Connection
  $effect(() => {
    if (socket && !channel) {
      const ch = socket.channel("editor:lobby", {});
      ch.join()
        .receive("ok", (resp) => {
          console.log("Joined EditorChannel", resp);
          connected = true;
          channel = ch;

          triggerPulse();

          // Streaming Protocol
          ch.on("filetree:chunk", (payload) => {
            const newFiles = NifDecoder.decodeChunk(payload.chunk, ".");
            // Incrementally update state
            fileTree.push(...newFiles);
          });

          ch.on("filetree:done", () => {
            // Final Sort
            fileTree.sort((a, b) => {
              if (a.type === "directory" && b.type !== "directory") return -1;
              if (a.type !== "directory" && b.type === "directory") return 1;
              return a.name.localeCompare(b.name);
            });

            // Auto-open README if present
            const readme = fileTree.find(
              (f) => f.name.toLowerCase() === "readme.md",
            );
            if (readme) openFile(readme);
          });

          // Delta Updates
          ch.on("filetree:delta", (payload) => {
            // Map backend types to delta handler types
            // Backend (Watcher): :created, :deleted, :modified, :renamed
            let type = payload.type;
            if (type === "created") type = "add";
            if (type === "deleted") type = "remove";
            if (type === "modified") type = "modify";

            // Apply delta (returns new array)
            fileTree = applyDelta(fileTree, { path: payload.path, type: type });
          });

          // Trigger stream
          fileTree = []; // Clear on load
          ch.push("filetree:list_raw", { path: "." });
        })
        .receive("error", (resp) => console.error("Failed", resp));
    }
  });

  function openFile(file) {
    showPalette = false;
    let group = editorGroups[activeGroupIndex];
    group.file = file;
    // content = null helps show loading spinner if we implemented that check
    // keeping simplistic for now
    if (channel) {
      channel
        .push("editor:read", { path: file.path })
        .receive("ok", (resp) => (group.content = resp.content));
    }
  }

  function splitEditor() {
    const current = editorGroups[activeGroupIndex];
    editorGroups.push({ file: current.file, content: current.content });
    activeGroupIndex = editorGroups.length - 1;
  }

  function toggleSidebar(section) {
    if (activeSidebar === section && sidebarVisible) {
      sidebarVisible = false;
    } else {
      activeSidebar = section;
      sidebarVisible = true;
    }
  }

  function handleRefactorSuccess(newCode) {
    editorGroups[activeGroupIndex].content = newCode;
  }

  function handleGlobalKeydown(e) {
    if (e.ctrlKey && e.key === "p") {
      e.preventDefault();
      paletteMode = "files";
      if (channel) {
        channel.push("editor:recent", {}).receive("ok", (resp) => {
          recentFiles = resp.files || [];
        });
      }
      showPalette = true;
    } else if (e.ctrlKey && e.shiftKey && e.key === "O") {
      e.preventDefault();
      paletteMode = "symbols";
      if (channel && activeGroup.file) {
        channel
          .push("lsp:symbols", { path: activeGroup.file.path })
          .receive("ok", (resp) => {
            documentSymbols = resp.symbols || [];
          });
      }
      showPalette = true;
    } else if (e.ctrlKey && e.shiftKey && e.key === "f") {
      e.preventDefault();
      toggleSidebar("search");
    } else if (e.ctrlKey && e.key === "\\") {
      e.preventDefault();
      splitEditor();
    }
  }
</script>

<div
  class="app-container bg-base-200 text-base-content select-none font-sans"
  onkeydown={handleGlobalKeydown}
  tabindex="-1"
  role="application"
>
  <TitleBar>
    <span
      class="hover:bg-white/10 px-2 py-0.5 rounded cursor-pointer transition-colors text-[11px] opacity-70"
      >File</span
    >
    <span
      class="hover:bg-white/10 px-2 py-0.5 rounded cursor-pointer transition-colors text-[11px] opacity-70"
      >Edit</span
    >
    <span
      class="hover:bg-white/10 px-2 py-0.5 rounded cursor-pointer transition-colors text-[11px] opacity-70"
      >Selection</span
    >
    <span
      class="hover:bg-white/10 px-2 py-0.5 rounded cursor-pointer transition-colors text-[11px] opacity-70"
      >View</span
    >
    <span
      class="hover:bg-white/10 px-2 py-0.5 rounded cursor-pointer transition-colors text-[11px] opacity-70"
      >Go</span
    >
    <span
      class="hover:bg-white/10 px-2 py-0.5 rounded cursor-pointer transition-colors text-[11px] opacity-70"
      >Run</span
    >
    <span
      class="hover:bg-white/10 px-2 py-0.5 rounded cursor-pointer transition-colors text-[11px] opacity-70"
      >Terminal</span
    >
    <span
      class="hover:bg-white/10 px-2 py-0.5 rounded cursor-pointer transition-colors text-[11px] opacity-70"
      >Help</span
    >
  </TitleBar>

  <main class="flex flex-1 overflow-hidden">
    <ActivityBar {activeSidebar} {sidebarVisible} onToggle={toggleSidebar} />

    <SideBar
      {activeSidebar}
      {sidebarVisible}
      {fileTree}
      activeFile={activeGroup.file}
      {channel}
      onOpenFile={openFile}
      onMenuClick={() => {}}
    />

    <div class="flex-1 flex flex-col min-w-0 bg-base-100">
      <EditorLayout
        bind:editorGroups
        bind:activeGroupIndex
        {channel}
        onSplit={splitEditor}
      />

      <!-- Bottom Panel (Terminal) -->
      <div class="flex flex-col h-64 shrink-0 transition-all">
        <div
          class="flex items-center bg-base-200 border-t border-base-content/10 px-4 h-9 min-h-[2.25rem] gap-4"
        >
          <span
            class="text-[11px] uppercase tracking-wider font-bold opacity-60 border-b border-primary h-full flex items-center"
            >Terminal</span
          >
          <span
            class="text-[11px] uppercase tracking-wider opacity-40 h-full flex items-center cursor-pointer hover:opacity-80"
            >Output</span
          >
          <span
            class="text-[11px] uppercase tracking-wider opacity-40 h-full flex items-center cursor-pointer hover:opacity-80"
            >Problems</span
          >
          <div class="flex-1"></div>
          <button class="opacity-40 hover:opacity-100 text-xs">✕</button>
        </div>
        <Terminal {channel} />
      </div>
    </div>
  </main>

  <StatusBar {nifPulse} activeFile={activeGroup.file} />
</div>

<!-- Modals -->
<RefactorModal
  isOpen={showRefactor}
  code={activeGroup.content}
  oldName="variable"
  {channel}
  onClose={() => (showRefactor = false)}
  onSuccess={handleRefactorSuccess}
/>

<CommandPalette
  isOpen={showPalette}
  items={fileTree}
  {recentFiles}
  symbols={documentSymbols}
  mode={paletteMode}
  onSelect={(item) => {
    if (paletteMode === "symbols" && item.line) {
      showPalette = false;
      window.dispatchEvent(
        new CustomEvent("goto-line", { detail: { line: item.line } }),
      );
    } else {
      openFile(item);
    }
  }}
  onClose={() => (showPalette = false)}
/>

<style>
  .app-container {
    display: flex;
    flex-direction: column;
    height: 100vh;
    width: 100vw;
  }
</style>
