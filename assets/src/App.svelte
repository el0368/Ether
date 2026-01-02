<script>
  // Svelte 5 Runes Mode
  let { socket } = $props();

  // Reactive state using $state rune
  let connected = $state(false);
  let fileTree = $state([]);
  let selectedFile = $state(null);
  let fileContent = $state("");

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

            // Auto-select README.md if found
            const readme = fileTree.find(
              (f) => f.name.toLowerCase() === "readme.md",
            );
            if (readme) {
              selectedFile = readme;
              ch.push("editor:read", { path: readme.path }).receive(
                "ok",
                (r) => {
                  fileContent = r.content;
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
  import Terminal from "./components/Terminal.svelte";
  import MonacoEditor from "./components/MonacoEditor.svelte";

  // Derived state
  let statusText = $derived(connected ? "🟢 Connected" : "🔴 Disconnected");

  // UI State
  let showRefactor = $state(false);
  let activeSidebar = $state("files");

  function handleRefactorSuccess(newCode) {
    fileContent = newCode;
    // Ideally we would also save the file here
  }
</script>

<div class="app-container bg-[#0d0f14] text-slate-200 select-none">
  <!-- VS Code Top Menu Bar -->
  <header
    class="h-8 bg-[#181818] flex items-center px-3 border-b border-white/5 shrink-0"
  >
    <div class="flex items-center gap-4 text-[12px] opacity-70">
      <span class="hover:bg-white/10 px-2 py-0.5 rounded cursor-pointer"
        >File</span
      >
      <span class="hover:bg-white/10 px-2 py-0.5 rounded cursor-pointer"
        >Edit</span
      >
      <span class="hover:bg-white/10 px-2 py-0.5 rounded cursor-pointer"
        >Selection</span
      >
      <span class="hover:bg-white/10 px-2 py-0.5 rounded cursor-pointer"
        >View</span
      >
      <span class="hover:bg-white/10 px-2 py-0.5 rounded cursor-pointer"
        >Go</span
      >
      <span class="hover:bg-white/10 px-2 py-0.5 rounded cursor-pointer"
        >Run</span
      >
      <span class="hover:bg-white/10 px-2 py-0.5 rounded cursor-pointer"
        >Terminal</span
      >
      <span class="hover:bg-white/10 px-2 py-0.5 rounded cursor-pointer"
        >Help</span
      >
    </div>
    <div class="flex-1 text-center text-[11px] opacity-40 font-medium">
      Aether - Antigravity - Task [Administrator]
    </div>
  </header>

  <!-- Main Workspace -->
  <main class="flex flex-1 overflow-hidden">
    <!-- VS Code Activity Bar (Far Left) -->
    <nav
      class="w-12 bg-[#333333] flex flex-col items-center py-2 gap-2 shrink-0"
    >
      <div class="flex flex-col gap-1 w-full">
        <button
          class="h-12 w-full flex items-center justify-center transition-all cursor-pointer text-xl border-l-2 {activeSidebar ===
          'files'
            ? 'border-white opacity-100 bg-white/5'
            : 'border-transparent opacity-40 hover:opacity-80'}"
          title="Explorer"
          onclick={() => (activeSidebar = "files")}>📁</button
        >
        <button
          class="h-12 w-full flex items-center justify-center transition-all cursor-pointer text-xl border-l-2 {activeSidebar ===
          'git'
            ? 'border-white opacity-100 bg-white/5'
            : 'border-transparent opacity-40 hover:opacity-80'}"
          title="Source Control"
          onclick={() => (activeSidebar = "git")}>🌿</button
        >
        <button
          class="h-12 w-full flex items-center justify-center transition-all cursor-pointer text-xl border-l-2 {activeSidebar ===
          'search'
            ? 'border-white opacity-100 bg-white/5'
            : 'border-transparent opacity-40 hover:opacity-80'}"
          title="Search"
          onclick={() => (activeSidebar = "search")}>🔍</button
        >
        <button
          class="h-12 w-full flex items-center justify-center transition-all cursor-pointer text-xl border-l-2 {activeSidebar ===
          'debug'
            ? 'border-white opacity-100 bg-white/5'
            : 'border-transparent opacity-40 hover:opacity-80'}"
          title="Run and Debug"
          onclick={() => (activeSidebar = "debug")}>▶️</button
        >
      </div>
      <div class="mt-auto flex flex-col gap-4 opacity-40 pb-4">
        <button class="text-lg hover:opacity-100">👤</button>
        <button class="text-lg hover:opacity-100">⚙️</button>
      </div>
    </nav>

    <!-- VS Code Sidebar (Explorer) -->
    <aside
      class="w-64 bg-[#252526] border-r border-white/5 flex flex-col overflow-hidden shrink-0"
    >
      <div class="p-3 flex items-center justify-between">
        <span class="text-[11px] font-bold uppercase tracking-wider opacity-60">
          {#if activeSidebar === "files"}Explorer{:else if activeSidebar === "git"}Source
            Control{:else}{activeSidebar}{/if}
        </span>
        <button class="opacity-40 hover:opacity-100">•••</button>
      </div>

      <!-- Content Area -->
      <div class="flex-1 overflow-hidden flex flex-col">
        {#if activeSidebar === "files"}
          <div
            class="flex items-center px-4 py-1 bg-white/5 gap-1 cursor-pointer"
          >
            <span class="text-[10px] opacity-40">▼</span>
            <span
              class="text-[11px] font-bold uppercase tracking-tight opacity-80"
              >Aether Project</span
            >
          </div>

          <div class="flex-1 overflow-auto py-2">
            {#if fileTree.length === 0}
              <div class="p-6 flex flex-col items-center gap-2 opacity-30">
                <span class="loading loading-spinner loading-xs"></span>
              </div>
            {:else}
              <ul class="menu menu-xs p-0 gap-0">
                {#each fileTree as file}
                  <li class="group">
                    <button
                      class="rounded-none px-4 py-1 transition-all text-white/50 hover:text-white hover:bg-white/5 border-l-2 border-transparent text-[13px] gap-2 items-center"
                      class:active-file={selectedFile === file}
                      onclick={() => {
                        selectedFile = file;
                        if (channel) {
                          channel
                            .push("editor:read", { path: file.path })
                            .receive(
                              "ok",
                              (resp) => (fileContent = resp.content),
                            );
                        }
                      }}
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
        {:else}
          <div class="p-8 text-center opacity-20 italic">
            Section arriving soon...
          </div>
        {/if}
      </div>

      <!-- Collapsible: Outline (Placeholder) -->
      <div class="bg-white/2 border-t border-white/5">
        <div
          class="flex items-center px-4 py-1 gap-1 cursor-pointer hover:bg-white/5"
        >
          <span class="text-[10px] opacity-40">▶</span>
          <span
            class="text-[11px] font-bold uppercase tracking-tight opacity-80"
            >Outline</span
          >
        </div>
      </div>

      <!-- Collapsible: Timeline (Placeholder) -->
      <div class="bg-white/2 border-t border-white/5">
        <div
          class="flex items-center px-4 py-1 gap-1 cursor-pointer hover:bg-white/5"
        >
          <span class="text-[10px] opacity-40">▶</span>
          <span
            class="text-[11px] font-bold uppercase tracking-tight opacity-80"
            >Timeline</span
          >
        </div>
      </div>
    </aside>

    <!-- VS Code Editor & Panel Central Area -->
    <div class="flex-1 flex flex-col min-w-0">
      <!-- Editor Tabs -->
      {#if selectedFile}
        <div
          class="flex items-center bg-[#181818] h-9 min-h-[2.25rem] overflow-x-auto no-scrollbar"
        >
          <div
            class="flex items-center bg-[#1e1e1e] h-full px-4 gap-2 border-r border-[#12151c] border-t-2 border-primary"
          >
            <span class="text-xs text-primary">📄</span>
            <span class="text-[12px] whitespace-nowrap"
              >{selectedFile.name}</span
            >
            <button class="ml-2 opacity-40 hover:opacity-100 text-[10px]"
              >✕</button
            >
          </div>
        </div>
      {/if}

      <section class="flex-1 flex flex-col bg-[#0d0f14] min-h-0 relative">
        {#if selectedFile}
          <div class="flex-1 overflow-hidden relative h-full min-h-0">
            {#if selectedFile.is_dir}
              <div
                class="flex h-full items-center justify-center text-white/10 bg-[#0d0f14]"
              >
                <div class="text-center">
                  <div class="text-8xl mb-4 font-black opacity-5">📁</div>
                </div>
              </div>
            {:else if !fileContent && selectedFile}
              <div class="flex h-full items-center justify-center bg-[#0d0f14]">
                <span
                  class="loading loading-ring loading-lg text-primary opacity-20"
                ></span>
              </div>
            {:else}
              <MonacoEditor
                value={fileContent}
                path={selectedFile.path}
                {channel}
                onChange={(val) => {
                  fileContent = val;
                }}
              />
            {/if}
          </div>
        {:else}
          <div class="flex-1 flex items-center justify-center bg-[#1e1e1e]">
            <div class="text-center opacity-20">
              <span class="text-9xl">⚡</span>
            </div>
          </div>
        {/if}
      </section>

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
      <div class="px-2 hover:bg-white/10 cursor-pointer">Elixir</div>
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
