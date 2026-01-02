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

<div class="app-container">
  <header class="navbar bg-base-200 px-4">
    <div class="flex-1 gap-2">
      <span class="text-xl font-bold">⚡ Aether IDE</span>
      {#if selectedFile}
        <div class="divider divider-horizontal"></div>
        <button
          class="btn btn-sm btn-ghost"
          onclick={() => (showRefactor = true)}
        >
          🔨 Refactor
        </button>
      {/if}
    </div>
    <div class="flex-none">
      <span class="badge badge-ghost">{statusText}</span>
    </div>
  </header>

  <main class="flex flex-1 overflow-hidden">
    <!-- Sidebar -->
    <aside
      class="w-64 bg-base-200 border-r border-base-300 flex flex-col overflow-hidden"
    >
      <div class="tabs tabs-boxed bg-base-200 p-2 rounded-none">
        <button
          class="tab flex-1 {activeSidebar === 'files' ? 'tab-active' : ''}"
          onclick={() => (activeSidebar = "files")}>Files</button
        >
        <button
          class="tab flex-1 {activeSidebar === 'git' ? 'tab-active' : ''}"
          onclick={() => (activeSidebar = "git")}>Git</button
        >
      </div>

      <div class="flex-1 overflow-auto">
        {#if activeSidebar === "files"}
          {#if fileTree.length === 0}
            <div class="p-4 text-sm text-base-content/50">Loading files...</div>
          {:else}
            <ul class="menu menu-xs">
              {#each fileTree as file}
                <li>
                  <button
                    class="truncate"
                    class:active={selectedFile === file}
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
                    {file.is_dir ? "📁" : "📄"}
                    {file.name}
                  </button>
                </li>
              {/each}
            </ul>
          {/if}
        {:else if activeSidebar === "git"}
          <GitPanel {channel} />
        {/if}
      </div>
    </aside>

    <!-- Main Editor Area -->
    <section class="flex-1 flex flex-col bg-base-100">
      {#if selectedFile}
        <div class="tabs tabs-boxed bg-base-200 p-1">
          <button class="tab tab-active">{selectedFile.name}</button>
        </div>
        <div class="flex-1 overflow-hidden relative">
          <MonacoEditor
            value={fileContent}
            path={selectedFile.path}
            {channel}
            onChange={(val) => {
              fileContent = val;
              // Debounce save or just let LSP handle did_change
              // Real saving would go here
            }}
          />
        </div>
      {:else}
        <div
          class="flex-1 flex items-center justify-center text-base-content/50"
        >
          <div class="text-center">
            <div class="text-6xl mb-4">⚡</div>
            <h2 class="text-2xl font-bold">Welcome to Aether</h2>
            <p class="mt-2">Select a file from the explorer to get started</p>
          </div>
        </div>
      {/if}
    </section>
  </main>

  <!-- Bottom Panel: Terminal -->
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
</style>
