<script>
  import { 
    FilePlus, 
    FileStack, 
    FolderOpen, 
    GitBranch, 
    Settings, 
    Zap,
    BookOpen,
    Palette,
    Keyboard
  } from "lucide-svelte";
  import { onMount } from "svelte";

  let { onNewFile, onOpenFile, onOpenFolder, recentFiles = [] } = $props();

  let showOnStartup = $state(true);

  onMount(() => {
    const saved = localStorage.getItem("showWelcomePage");
    if (saved !== null) {
      showOnStartup = saved === "true";
    }
  });

  function toggleStartup(e) {
    showOnStartup = e.target.checked;
    localStorage.setItem("showWelcomePage", showOnStartup.toString());
  }
</script>

<div class="flex-1 overflow-y-auto bg-[var(--vscode-editor-background)] text-[var(--vscode-editor-foreground)] flex flex-col items-center py-16 px-8 select-none">
  <div class="max-w-5xl w-full flex flex-col gap-12">
    
    <!-- Hero Header -->
    <header class="flex flex-col gap-2">
      <h1 class="text-4xl font-light tracking-tight flex items-center gap-3">
        Ether IDE
      </h1>
      <p class="text-xl opacity-60 font-light">
        Industrial development evolved.
      </p>
    </header>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-16">
      
      <!-- Left Column: Start & Recent -->
      <div class="flex flex-col gap-8">
        
        <!-- Start Section -->
        <section class="flex flex-col gap-4">
          <h2 class="text-lg font-medium opacity-80">Start</h2>
          <div class="flex flex-col gap-2">
            <button onclick={onNewFile} class="flex items-center gap-3 text-[var(--vscode-textLink-foreground)] hover:underline group w-fit">
              <FilePlus size={18} class="opacity-70 group-hover:opacity-100" />
              <span>New File...</span>
            </button>
            <button onclick={onOpenFile} class="flex items-center gap-3 text-[var(--vscode-textLink-foreground)] hover:underline group w-fit">
              <FileStack size={18} class="opacity-70 group-hover:opacity-100" />
              <span>Open File...</span>
            </button>
            <button onclick={onOpenFolder} class="flex items-center gap-3 text-[var(--vscode-textLink-foreground)] hover:underline group w-fit">
              <FolderOpen size={18} class="opacity-70 group-hover:opacity-100" />
              <span>Open Folder...</span>
            </button>
            <button class="flex items-center gap-3 text-[var(--vscode-textLink-foreground)] hover:underline group w-fit opacity-50 cursor-not-allowed">
              <GitBranch size={18} />
              <span>Clone Git Repository...</span>
            </button>
          </div>
        </section>

        <!-- Recent Section -->
        <section class="flex flex-col gap-4">
          <h2 class="text-lg font-medium opacity-80">Recent</h2>
          <div class="flex flex-col gap-1">
            {#each recentFiles.slice(0, 5) as file}
              <button onclick={() => onOpenFile(file)} class="flex flex-col items-start gap-0.5 p-2 rounded hover:bg-white/5 transition-colors group">
                <span class="text-sm font-medium text-[var(--vscode-textLink-foreground)] group-hover:underline">{file.name}</span>
                <span class="text-[11px] opacity-40">{file.path}</span>
              </button>
            {:else}
              <div class="text-sm opacity-40 italic py-2">No recent files</div>
            {/each}
            {#if recentFiles.length > 5}
              <button class="text-xs text-[var(--vscode-textLink-foreground)] hover:underline mt-2">More...</button>
            {/if}
          </div>
        </section>
      </div>

      <!-- Right Column: Walkthroughs -->
      <div class="flex flex-col gap-8">
        <h2 class="text-lg font-medium opacity-80">Walkthroughs</h2>
        
        <div class="flex flex-col gap-3">
          <!-- Walkthrough Card -->
          <button class="flex items-start gap-4 p-4 rounded-lg bg-white/[0.03] border border-white/[0.05] hover:bg-white/[0.06] transition-all text-left group">
            <div class="w-10 h-10 rounded bg-indigo-500/20 flex items-center justify-center text-indigo-400">
              <Zap size={20} />
            </div>
            <div class="flex flex-col gap-1">
              <h3 class="text-sm font-bold">Get Started with Ether</h3>
              <p class="text-xs opacity-60 leading-relaxed">Discover the industrial engine, native reflexes, and AI-powered workflows.</p>
            </div>
          </button>

          <button class="flex items-start gap-4 p-4 rounded-lg bg-white/[0.03] border border-white/[0.05] hover:bg-white/[0.06] transition-all text-left group">
            <div class="w-10 h-10 rounded bg-emerald-500/20 flex items-center justify-center text-emerald-400">
              <BookOpen size={20} />
            </div>
            <div class="flex flex-col gap-1">
              <h3 class="text-sm font-bold">Learn the Fundamentals</h3>
              <p class="text-xs opacity-60 leading-relaxed">Master the BEAM, Zig NIFs, and project orchestration.</p>
            </div>
          </button>

          <button class="flex items-start gap-4 p-4 rounded-lg bg-white/[0.03] border border-white/[0.05] hover:bg-white/[0.06] transition-all text-left group">
            <div class="w-10 h-10 rounded bg-amber-500/20 flex items-center justify-center text-amber-400">
              <Palette size={20} />
            </div>
            <div class="flex flex-col gap-1">
              <h3 class="text-sm font-bold">Customize your Dashboard</h3>
              <p class="text-xs opacity-60 leading-relaxed">Sync themes, configure your studio, and tune your observatory.</p>
            </div>
          </button>
        </div>

        <div class="mt-4 flex flex-col gap-3">
          <button class="flex items-center gap-3 text-sm opacity-60 hover:opacity-100 transition-opacity">
            <Keyboard size={16} />
            <span>Show all Commands</span>
            <span class="ml-auto text-[10px] opacity-40 font-mono">Ctrl+Shift+P</span>
          </button>
        </div>
      </div>

    </div>

    <!-- Footer -->
    <footer class="mt-auto pt-12 border-t border-white/[0.05] flex items-center justify-center">
      <label class="flex items-center gap-2 cursor-pointer group">
        <input 
          type="checkbox" 
          checked={showOnStartup} 
          onchange={toggleStartup}
          class="rounded border-white/20 bg-transparent text-indigo-600 focus:ring-0 focus:ring-offset-0"
        />
        <span class="text-xs opacity-50 group-hover:opacity-100 transition-opacity">Show welcome page on startup</span>
      </label>
    </footer>

  </div>
</div>
