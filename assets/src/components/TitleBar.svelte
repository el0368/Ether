<script>
  import { getCurrentWindow } from "@tauri-apps/api/window";
  import { onMount } from "svelte";

  let { children } = $props();
  let appWindow = $state(null);

  // Safely initialize Tauri window context
  onMount(() => {
    try {
      if (window.__TAURI_INTERNALS__) {
        appWindow = getCurrentWindow();
      }
    } catch (e) {
      console.warn("Tauri window context not available:", e);
    }
  });

  async function minimize() {
    if (appWindow) await appWindow.minimize();
  }

  async function toggleMaximize() {
    if (!appWindow) return;
    const isMaximized = await appWindow.isMaximized();
    if (isMaximized) {
      await appWindow.unmaximize();
    } else {
      await appWindow.maximize();
    }
  }

  function handleTitleDoubleClick(e) {
    // Ignore double clicks on buttons to prevent conflict
    if (e && e.target && e.target.closest("button")) return;
    toggleMaximize();
  }

  async function close() {
    if (appWindow) await appWindow.close();
  }
</script>

<!-- Main TitleBar Container with Drag Region -->
<!-- svelte-ignore a11y_no_static_element_interactions -->
<div
  class="h-8 bg-[#181818] flex items-center justify-between border-b border-white/[0.05] select-none shrink-0"
  data-tauri-drag-region
  ondblclick={handleTitleDoubleClick}
>
  <!-- Left Section: Logo & Menu -->
  <div
    class="flex items-center gap-1 pl-2 h-full overflow-hidden pointer-events-none"
  >
    <!-- App Logo/Name -->
    <div class="flex items-center gap-2 mr-2" data-tauri-drag-region>
      <div
        class="w-3 h-3 rounded-full bg-gradient-to-br from-indigo-500 to-purple-500"
      ></div>
      <span class="text-xs font-bold text-white/50 tracking-wider">ETHER</span>
    </div>

    <!-- Menu Slot (Pass in buttons from parent) -->
    <div class="flex items-center h-full pointer-events-auto">
      {@render children?.()}
    </div>
  </div>

  <!-- Right Section: Status & Window Controls -->
  <div class="flex items-center h-full" data-tauri-drag-region>
    <!-- Native Badge -->
    <div
      class="px-2 py-0.5 rounded bg-[#1e1e1e] text-emerald-500 text-[9px] font-mono mr-2 border border-emerald-500/20 shadow-sm pointer-events-none"
    >
      NATIVE: ZIG
    </div>

    <!-- Controls (Only show if in Tauri) -->
    {#if appWindow}
      <button
        class="h-full w-10 hover:bg-white/10 text-white/60 transition-colors flex items-center justify-center cursor-default z-50 pointer-events-auto"
        onclick={minimize}
        title="Minimize"
      >
        <span class="text-[10px]">─</span>
      </button>

      <button
        class="h-full w-10 hover:bg-white/10 text-white/60 transition-colors flex items-center justify-center cursor-default z-50 pointer-events-auto"
        onclick={toggleMaximize}
        title="Maximize"
      >
        <span class="text-[10px]">□</span>
      </button>

      <button
        class="h-full w-10 hover:bg-red-500 hover:text-white text-white/60 transition-colors flex items-center justify-center cursor-default z-50 pointer-events-auto"
        onclick={close}
        title="Close"
      >
        <span class="text-[10px]">✕</span>
      </button>
    {/if}
  </div>
</div>
