<script>
  // Svelte 5 Runes Mode
  let { socket } = $props();

  // Reactive state using $state rune
  let connected = $state(false);
  let fileTree = $state([]);

  // Multi-pane / Split View State
  let editorGroups = $state([{ file: null, content: "" }]);
  let activeGroupIndex = $state(0);

  // Helper to get active state
  let activeGroup = $derived(editorGroups[activeGroupIndex]);

  // Channel reference
  let channel = $state(null);

  // Connect to EditorChannel when socket is ready
  $effect(() => {
    if (socket && !channel) {
      const ch = socket.channel("editor:lobby", {});

      ch.join()
        .receive("ok", (resp) => {
          console.log("Joined EditorChannel", resp);
          connected = true;
          channel = ch;

          // Request initial file tree
          ch.push("filetree:list", { path: "." }).receive("ok", (resp) => {
            fileTree = resp.files || [];

            // Auto-select README.md if found in the first pane
            const readme = fileTree.find(
              (f) => f.name.toLowerCase() === "readme.md",
            );
            if (readme) {
              editorGroups[0].file = readme;
              ch.push("editor:read", { path: readme.path }).receive(
                "ok",
                (r) => {
                  editorGroups[0].content = r.content;
                },
              );
            }
          });
        })
        .receive("error", (resp) => {
          console.error("Failed to join EditorChannel", resp);
        });
    }
  });

  import RefactorModal from "./components/RefactorModal.svelte";
  import GitPanel from "./components/GitPanel.svelte";
  import SearchPanel from "./components/SearchPanel.svelte";
  import Terminal from "./components/Terminal.svelte";
  import MonacoEditor from "./components/MonacoEditor.svelte";

  import CommandPalette from "./components/CommandPalette.svelte";

  // Derived state
  let statusText = $derived(connected ? "🟢 Connected" : "🔴 Disconnected");

  // UI State
  let showRefactor = $state(false);
  let showPalette = $state(false);
  let activeSidebar = $state("files");
  let sidebarVisible = $state(true);

  function handleGlobalKeydown(e) {
    if (e.ctrlKey && e.key === "p") {
      e.preventDefault();
      showPalette = true;
    } else if (e.ctrlKey && e.shiftKey && e.key === "f") {
      e.preventDefault();
      activeSidebar = "search";
      sidebarVisible = true;
    } else if (e.ctrlKey && e.key === "\\") {
      // VS Code split shortcut Ctrl+\
      e.preventDefault();
      splitEditor();
    }
  }

  function openFile(file) {
    showPalette = false;
    let group = editorGroups[activeGroupIndex];
    group.file = file;
    if (channel) {
      channel
        .push("editor:read", { path: file.path })
        .receive("ok", (resp) => (group.content = resp.content));
    }
  }

  function splitEditor() {
    const current = editorGroups[activeGroupIndex];
    editorGroups.push({
      file: current.file,
      content: current.content,
    });
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
</script>

<div
  class="app-container bg-[#1e1e1e] text-[#cccccc] select-none font-sans"
  onkeydown={handleGlobalKeydown}
  tabindex="-1"
>
  <!-- VS Code Top Menu Bar -->
  <header
    class="h-9 bg-[#181818] flex items-center px-3 border-b border-white/[0.03] shrink-0"
  >
    <div class="flex items-center gap-4 text-[13px] opacity-70">
      <span
        class="hover:bg-white/10 px-2 py-0.5 rounded cursor-pointer transition-colors"
        >File</span
      >
      <span
        class="hover:bg-white/10 px-2 py-0.5 rounded cursor-pointer transition-colors"
        >Edit</span
      >
      <span
        class="hover:bg-white/10 px-2 py-0.5 rounded cursor-pointer transition-colors"
        >Selection</span
      >
      <span
        class="hover:bg-white/10 px-2 py-0.5 rounded cursor-pointer transition-colors"
        >View</span
      >
      <span
        class="hover:bg-white/10 px-2 py-0.5 rounded cursor-pointer transition-colors"
        >Go</span
      >
      <span
        class="hover:bg-white/10 px-2 py-0.5 rounded cursor-pointer transition-colors"
        >Run</span
      >
      <span
        class="hover:bg-white/10 px-2 py-0.5 rounded cursor-pointer transition-colors"
        >Terminal</span
      >
      <span
        class="hover:bg-white/10 px-2 py-0.5 rounded cursor-pointer transition-colors"
        >Help</span
      >
    </div>
    <div class="flex-1 text-center text-[12px] opacity-40 font-medium">
      Aether - Antigravity - Task [Administrator]
    </div>
  </header>

  <!-- Main Workspace -->
  <main class="flex flex-1 overflow-hidden">
    <!-- VS Code Activity Bar (Far Left) -->
    <nav
      class="w-12 bg-[#333333] flex flex-col items-center py-2 gap-2 shrink-0 border-r border-white/[0.03]"
    >
      <div class="flex flex-col gap-1 w-full">
        <button
          class="h-12 w-full flex items-center justify-center transition-all cursor-pointer text-xl border-l-[3px] {activeSidebar ===
            'files' && sidebarVisible
            ? 'border-white opacity-100 bg-white/5'
            : 'border-transparent opacity-40 hover:opacity-80'}"
          title="Explorer"
          onclick={() => toggleSidebar("files")}>📁</button
        >
        <button
          class="h-12 w-full flex items-center justify-center transition-all cursor-pointer text-xl border-l-[3px] {activeSidebar ===
            'git' && sidebarVisible
            ? 'border-white opacity-100 bg-white/5'
            : 'border-transparent opacity-40 hover:opacity-80'}"
          title="Source Control"
          onclick={() => toggleSidebar("git")}>🌿</button
        >
        <button
          class="h-12 w-full flex items-center justify-center transition-all cursor-pointer text-xl border-l-[3px] {activeSidebar ===
            'search' && sidebarVisible
            ? 'border-white opacity-100 bg-white/5'
            : 'border-transparent opacity-40 hover:opacity-80'}"
          title="Search"
          onclick={() => toggleSidebar("search")}>🔍</button
        >
        <button
          class="h-12 w-full flex items-center justify-center transition-all cursor-pointer text-xl border-l-[3px] {activeSidebar ===
            'debug' && sidebarVisible
            ? 'border-white opacity-100 bg-white/5'
            : 'border-transparent opacity-40 hover:opacity-80'}"
          title="Run and Debug"
          onclick={() => toggleSidebar("debug")}>▶️</button
        >
      </div>
      <div class="mt-auto flex flex-col gap-4 opacity-40 pb-4">
        <button class="text-lg hover:opacity-100 transition-opacity">👤</button>
        <button class="text-lg hover:opacity-100 transition-opacity">⚙️</button>
      </div>
    </nav>

    <!-- VS Code Sidebar (Explorer) -->
    {#if sidebarVisible}
      <aside
        class="w-64 bg-[#252526] border-r border-black/20 flex flex-col overflow-hidden shrink-0"
      >
        <div class="p-3 pl-5 flex items-center justify-between">
          <span
            class="text-[11px] font-medium uppercase tracking-wider opacity-60"
          >
            {#if activeSidebar === "files"}Explorer{:else if activeSidebar === "git"}Source
              Control{:else}{activeSidebar}{/if}
          </span>
          <button class="opacity-40 hover:opacity-100 pr-2">•••</button>
        </div>

        <!-- Content Area -->
        <div class="flex-1 overflow-hidden flex flex-col">
          {#if activeSidebar === "files"}
            <div
              class="flex items-center px-1 py-1 bg-white/[0.03] gap-1 cursor-pointer"
            >
              <span class="text-[10px] opacity-40 ml-1">▼</span>
              <span
                class="text-[11px] font-bold uppercase tracking-tight opacity-70"
                >Aether Project</span
              >
            </div>

            <div class="flex-1 overflow-auto py-1">
              {#if fileTree.length === 0}
                <div class="p-6 flex flex-col items-center gap-2 opacity-30">
                  <span class="loading loading-spinner loading-xs"></span>
                </div>
              {:else}
                <ul class="menu menu-xs p-0 gap-0">
                  {#each fileTree as file}
                    <li class="group">
                      <button
                        class="rounded-none px-4 py-1 transition-all text-[#cccccc] hover:text-white hover:bg-white/[0.05] border-l-2 border-transparent text-[13px] gap-2 items-center"
                        class:active-file={selectedFile === file}
                        onclick={() => openFile(file)}
                      >
                        <span class="text-xs opacity-40 shrink-0"
                          >{file.is_dir ? "📁" : "📄"}</span
                        >
                        <span class="truncate">{file.name}</span>
                      </button>
                    </li>
                  {/each}
                </ul>
              {/if}
            </div>
          {:else if activeSidebar === "git"}
            <div class="p-4">
              <GitPanel {channel} />
            </div>
          {:else if activeSidebar === "search"}
            <SearchPanel
              {channel}
              onSelectFile={(file) => {
                openFile(file);
              }}
            />
          {:else}
            <div class="p-8 text-center opacity-20 italic text-sm">
              Section arriving soon...
            </div>
          {/if}
        </div>

        <!-- Collapsible: Outline (Placeholder) -->
        <div class="bg-white/2 border-t border-black/20">
          <div
            class="flex items-center px-4 py-1 gap-1 cursor-pointer hover:bg-white/5"
          >
            <span class="text-[10px] opacity-40">▶</span>
            <span
              class="text-[11px] font-bold uppercase tracking-tight opacity-60"
              >Outline</span
            >
          </div>
        </div>

        <!-- Collapsible: Timeline (Placeholder) -->
        <div class="bg-white/2 border-t border-black/20">
          <div
            class="flex items-center px-4 py-1 gap-1 cursor-pointer hover:bg-white/5"
          >
            <span class="text-[10px] opacity-40">▶</span>
            <span
              class="text-[11px] font-bold uppercase tracking-tight opacity-60"
              >Timeline</span
            >
          </div>
        </div>
      </aside>
    {/if}

    <!-- VS Code Editor & Panel Central Area -->
    <div class="flex-1 flex flex-col min-w-0 bg-[#0d0f14]">
      <div class="flex-1 flex overflow-hidden">
        {#each editorGroups as group, idx}
          <!-- Pane -->
          <div
            class="flex-1 flex flex-col min-w-0 border-r border-white/5 last:border-r-0 relative group/pane {idx ===
            activeGroupIndex
              ? 'bg-[#1e1e1e]'
              : 'opacity-80'}"
            onclick={() => (activeGroupIndex = idx)}
          >
            <!-- Editor Tabs -->
            <div
              class="flex items-center bg-[#252526] h-9 min-h-[2.25rem] overflow-x-auto no-scrollbar justify-between"
            >
              <div class="flex items-center h-full">
                {#if group.file}
                  <div
                    class="flex items-center {idx === activeGroupIndex
                      ? 'bg-[#1e1e1e] border-t border-t-primary'
                      : 'bg-[#2d2d2d]'} h-full px-4 gap-2 border-r border-black/20"
                  >
                    <span class="text-xs text-primary opacity-60">📄</span>
                    <span class="text-[13px] whitespace-nowrap text-[#cccccc]"
                      >{group.file.name}</span
                    >
                    <button
                      class="ml-2 opacity-20 hover:opacity-100 text-[10px]"
                      onclick={(e) => {
                        e.stopPropagation();
                        if (editorGroups.length > 1) {
                          editorGroups.splice(idx, 1);
                          activeGroupIndex = Math.min(
                            activeGroupIndex,
                            editorGroups.length - 1,
                          );
                        } else {
                          group.file = null;
                          group.content = "";
                        }
                      }}>✕</button
                    >
                  </div>
                {/if}
              </div>

              <!-- Actions -->
              <div class="flex items-center px-2 gap-2">
                <button
                  class="opacity-40 hover:opacity-100 text-xs p-1 hover:bg-white/5 rounded"
                  title="Split Editor Right"
                  onclick={(e) => {
                    e.stopPropagation();
                    splitEditor();
                  }}>◫</button
                >
                <button
                  class="opacity-40 hover:opacity-100 text-xs p-1 hover:bg-white/5 rounded"
                  >•••</button
                >
              </div>
            </div>

            <!-- Breadcrumbs -->
            {#if group.file}
              <div
                class="h-6 flex items-center px-4 bg-[#1e1e1e] border-b border-black/10 text-[11px] opacity-40 gap-1"
              >
                <span>Aether</span>
                <span>›</span>
                <span class="font-bold"
                  >{group.file.path.split("/").join(" › ")}</span
                >
              </div>
            {/if}

            <!-- Main Editor Area -->
            <section class="flex-1 flex flex-col bg-[#0d0f14] min-h-0 relative">
              {#if group.file}
                <div class="flex-1 overflow-hidden relative h-full min-h-0">
                  {#if group.file.is_dir}
                    <div
                      class="flex h-full items-center justify-center text-white/10 bg-[#0d0f14]"
                    >
                      <div class="text-center">
                        <div class="text-8xl mb-4 font-black opacity-5">📁</div>
                      </div>
                    </div>
                  {:else if !group.content}
                    <div
                      class="flex h-full items-center justify-center bg-[#0d0f14]"
                    >
                      <span
                        class="loading loading-ring loading-lg text-primary opacity-20"
                      ></span>
                    </div>
                  {:else}
                    <MonacoEditor
                      value={group.content}
                      path={group.file.path}
                      {channel}
                      onChange={(val) => {
                        group.content = val;
                      }}
                    />
                  {/if}
                </div>
              {:else}
                <div
                  class="flex-1 flex items-center justify-center bg-[#1e1e1e]"
                >
                  <div class="text-center opacity-20">
                    <span class="text-9xl">⚡</span>
                  </div>
                </div>
              {/if}
            </section>
          </div>
        {/each}
      </div>

      <!-- VS Code Panel (Terminal) -->
      <div class="flex flex-col h-64 shrink-0 transition-all">
        <div
          class="flex items-center bg-[#1e1e1e] border-t border-white/5 px-4 h-9 min-h-[2.25rem] gap-4"
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

  <!-- VS Code Status Bar (Bottom) -->
  <footer
    class="h-6 bg-[#007acc] flex items-center px-4 text-[11px] text-white shrink-0 justify-between"
  >
    <div class="flex items-center gap-4">
      <div
        class="flex items-center gap-1 hover:bg-white/10 px-2 h-full cursor-pointer"
      >
        <span>🌿</span>
        <span class="font-medium">main*</span>
      </div>
      <div class="flex items-center gap-2">
        <span>⊗ 0</span>
        <span>⚠ 0</span>
      </div>
    </div>
    <div class="flex items-center gap-4">
      <div class="opacity-80">Line 1, Col 1</div>
      <div class="opacity-80">UTF-8</div>
      <div class="px-2 hover:bg-white/10 cursor-pointer">
        {#if activeGroup.file}
          {activeGroup.file.name.split(".").pop() === "ex"
            ? "Elixir"
            : activeGroup.file.name.split(".").pop().toUpperCase()}
        {:else}
          Plain Text
        {/if}
      </div>
      <div class="flex items-center gap-1">
        <span>🔔</span>
      </div>
    </div>
  </footer>
</div>

<RefactorModal
  isOpen={showRefactor}
  code={fileContent}
  oldName="variable"
  {channel}
  onClose={() => (showRefactor = false)}
  onSuccess={handleRefactorSuccess}
/>

<CommandPalette
  isOpen={showPalette}
  items={fileTree}
  onSelect={(file) => openFile(file)}
  onClose={() => (showPalette = false)}
/>

<style>
  .app-container {
    display: flex;
    flex-direction: column;
    height: 100vh;
    width: 100vw;
  }

  main {
    flex: 1;
    display: flex;
    overflow: hidden;
  }

  .active-file {
    background-color: #37373d !important;
    color: white !important;
  }
</style>
