<script>
  // Svelte 5 Runes Mode
  let { socket } = $props()
  
  // Reactive state using $state rune
  let connected = $state(false)
  let fileTree = $state([])
  let selectedFile = $state(null)
  let fileContent = $state('')
  
  // Channel reference
  let channel = $state(null)
  
  // Connect to EditorChannel when socket is ready
  $effect(() => {
    if (socket && !channel) {
      const ch = socket.channel("editor:lobby", {})
      
      ch.join()
        .receive("ok", resp => {
          console.log("Joined EditorChannel", resp)
          connected = true
          channel = ch
          
          // Request initial file tree
          ch.push("filetree:list", { path: "." })
            .receive("ok", resp => {
              fileTree = resp.files || []
            })
        })
        .receive("error", resp => {
          console.error("Failed to join EditorChannel", resp)
        })
    }
  })
  
  // Derived state
  let statusText = $derived(connected ? "🟢 Connected" : "🔴 Disconnected")
</script>

<div class="app-container">
  <header class="navbar bg-base-200 px-4">
    <div class="flex-1">
      <span class="text-xl font-bold">⚡ Aether IDE</span>
    </div>
    <div class="flex-none">
      <span class="badge badge-ghost">{statusText}</span>
    </div>
  </header>
  
  <main class="flex flex-1 overflow-hidden">
    <!-- Sidebar: File Tree -->
    <aside class="w-64 bg-base-200 border-r border-base-300 overflow-auto">
      <div class="p-2 text-sm font-semibold text-base-content/70">
        EXPLORER
      </div>
      {#if fileTree.length === 0}
        <div class="p-4 text-sm text-base-content/50">
          Loading files...
        </div>
      {:else}
        <ul class="menu menu-xs">
          {#each fileTree as file}
            <li>
              <button 
                class="truncate"
                class:active={selectedFile === file}
                onclick={() => selectedFile = file}
              >
                {file.is_dir ? '📁' : '📄'} {file.name}
              </button>
            </li>
          {/each}
        </ul>
      {/if}
    </aside>
    
    <!-- Main Editor Area -->
    <section class="flex-1 flex flex-col bg-base-100">
      {#if selectedFile}
        <div class="tabs tabs-boxed bg-base-200 p-1">
          <button class="tab tab-active">{selectedFile.name}</button>
        </div>
        <div class="flex-1 p-4 font-mono text-sm">
          <pre>{fileContent || 'Select a file to view its contents'}</pre>
        </div>
      {:else}
        <div class="flex-1 flex items-center justify-center text-base-content/50">
          <div class="text-center">
            <div class="text-6xl mb-4">⚡</div>
            <h2 class="text-2xl font-bold">Welcome to Aether</h2>
            <p class="mt-2">Select a file from the explorer to get started</p>
          </div>
        </div>
      {/if}
    </section>
  </main>
</div>

<style>
  .app-container {
    display: flex;
    flex-direction: column;
    height: 100vh;
    width: 100vw;
  }
  
  main {
    flex: 1;
    overflow: hidden;
  }
</style>
