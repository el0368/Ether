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

<div class="app-container bg-[#0d0f14] text-slate-200">
  <!-- Top Navigation -->
  <header class="navbar bg-[#12151c] border-b border-white/5 px-6 shadow-2xl">
    <div class="flex-1 gap-4 items-center">
      <div class="flex items-center gap-2">
        <span class="text-primary text-2xl">⚡</span>
        <span class="text-sm font-bold tracking-widest uppercase opacity-80"
          >Aether <span class="text-xs font-normal opacity-50 ml-1">v2.0</span
          ></span
        >
      </div>

      {#if selectedFile}
        <div class="h-4 w-px bg-white/10 mx-2"></div>
        <div class="flex items-center gap-2 text-xs font-medium opacity-60">
          <span>{selectedFile.path}</span>
        </div>
      {/if}
    </div>

    <div class="flex-none gap-2">
      {#if selectedFile}
        <button
          class="btn btn-xs btn-primary bg-blue-600 border-none hover:bg-blue-500 transition-all duration-300 rounded"
          onclick={() => (showRefactor = true)}
        >
          🔨 Refactor
        </button>
      {/if}
      <div class="h-4 w-px bg-white/10 mx-2"></div>
      <span
        class="text-[10px] uppercase font-bold tracking-tighter opacity-40 mr-2"
        >{statusText}</span
      >
    </div>
  </header>

  <main class="flex flex-1 overflow-hidden">
    <!-- Sophisticated Sidebar -->
    <aside
      class="w-72 bg-[#12151c] border-r border-white/5 flex flex-col overflow-hidden"
    >
      <div class="p-4 border-b border-white/5 bg-white/2">
        <h3
          class="text-[10px] font-black uppercase tracking-[0.2em] text-white/30"
        >
          Explorer
        </h3>
        <div class="mt-1 flex items-center justify-between">
          <span class="text-xs font-semibold text-white/70">Aether Project</span
          >
          <span class="text-[10px] text-white/20">ROOT</span>
        </div>
      </div>

      <div class="tabs tabs-boxed bg-transparent p-2 gap-1">
        <button
          class="btn btn-xs flex-1 transition-all {activeSidebar === 'files'
            ? 'btn-active bg-white/10 border-white/10'
            : 'btn-ghost text-white/40 border-transparent hover:bg-white/5'}"
          onclick={() => (activeSidebar = "files")}>Files</button
        >
        <button
          class="btn btn-xs flex-1 transition-all {activeSidebar === 'git'
            ? 'btn-active bg-white/10 border-white/10'
            : 'btn-ghost text-white/40 border-transparent hover:bg-white/5'}"
          onclick={() => (activeSidebar = "git")}>Version Control</button
        >
      </div>

      <div class="flex-1 overflow-auto py-2">
        {#if activeSidebar === "files"}
          {#if fileTree.length === 0}
            <div class="p-6 flex flex-col items-center gap-2 opacity-30">
              <span class="loading loading-spinner loading-sm"></span>
            </div>
          {:else}
            <ul class="menu menu-xs p-0 px-2 gap-0.5">
              {#each fileTree as file}
                <li class="group">
                  <button
                    class="rounded px-2 py-1.5 transition-all text-white/60 hover:text-white hover:bg-white/5 border-l-2 border-transparent"
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
                    <span class="truncate font-medium">{file.name}</span>
                  </button>
                </li>
              {/each}
            </ul>
          {/if}
        {:else if activeSidebar === "git"}
          <div class="p-4">
            <GitPanel {channel} />
          </div>
        {/if}
      </div>
    </aside>

    <!-- Main Editor Area -->
    <section class="flex-1 flex flex-col bg-[#0d0f14] min-h-0 relative">
      {#if selectedFile}
        <div
          class="flex items-center bg-[#12151c] border-b border-white/5 h-10 px-4 gap-2"
        >
          <span class="text-xs text-primary">📄</span>
          <span class="text-xs font-bold text-white/80"
            >{selectedFile.name}</span
          >
          <div class="flex-1"></div>
          <span class="text-[9px] font-mono text-white/20 uppercase"
            >Modified</span
          >
        </div>

        <div class="flex-1 overflow-hidden relative h-full min-h-0">
          {#if selectedFile.is_dir}
            <div
              class="flex h-full items-center justify-center text-white/20 bg-[#0d0f14]"
            >
              <div class="text-center">
                <div class="text-5xl mb-4 opacity-10">📁</div>
                <p class="text-sm font-light tracking-wide italic">
                  Directory selected
                </p>
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
        <div class="flex-1 flex items-center justify-center bg-[#0d0f14]">
          <div
            class="max-w-md w-full p-8 text-center glass-panel rounded-2xl shadow-2xl border-white/5"
          >
            <div
              class="text-7xl mb-6 bg-gradient-to-br from-blue-400 to-indigo-600 bg-clip-text text-transparent"
            >
              ⚡
            </div>
            <h2 class="text-3xl font-black tracking-tighter text-white">
              IGNITE YOUR CODE
            </h2>
            <p class="mt-4 text-white/40 text-sm leading-relaxed font-light">
              Welcome to the Aether Intelligent Engine. Select a source file to
              begin your agentic journey.
            </p>
            <div class="mt-10 flex flex-col gap-3">
              <button
                class="btn btn-primary btn-md normal-case font-bold tracking-tight rounded-xl"
                onclick={() => {
                  const readme = fileTree.find(
                    (f) => f.name.toLowerCase() === "readme.md",
                  );
                  if (readme) {
                    selectedFile = readme;
                    channel
                      .push("editor:read", { path: readme.path })
                      .receive("ok", (r) => (fileContent = r.content));
                  }
                }}
              >
                Explore README.md
              </button>
              <span
                class="text-[10px] font-bold uppercase tracking-widest opacity-20 mt-2"
                >Built for high-performance agents</span
              >
            </div>
          </div>
        </div>
      {/if}
    </section>
  </main>

  <Terminal {channel} />
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
    background-color: rgba(59, 130, 246, 0.15) !important;
    color: white !important;
    border-left-color: #3b82f6 !important;
  }
</style>
