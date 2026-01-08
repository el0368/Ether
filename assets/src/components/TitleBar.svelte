<script>
  import { getCurrentWindow } from "@tauri-apps/api/window";
  import { onMount } from "svelte";
  import { SunMoon, Zap } from "lucide-svelte";

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

  function toggleTheme() {
    const html = document.documentElement;
    const current = html.getAttribute("data-theme") || "dark";
    const next = current === "dark" ? "light" : "dark";
    html.setAttribute("data-theme", next);
    localStorage.setItem("theme", next);
    // Dispatch event for Monaco etc.
    window.dispatchEvent(new CustomEvent("theme-changed", { detail: next }));
  }
</script>

<!-- Main TitleBar Container with Drag Region -->
<!-- svelte-ignore a11y_no_static_element_interactions -->
<div
  class="h-8 bg-[var(--vscode-titleBar-activeBackground)] flex items-center justify-between border-b border-[var(--vscode-titleBar-border)] select-none shrink-0"
  data-tauri-drag-region
  ondblclick={handleTitleDoubleClick}
>
  <!-- Left Section: Logo & Menu -->
  <div
    class="flex items-center gap-1 pl-2 h-full"
  >
    <!-- App Logo/Name -->
    <div class="flex items-center gap-2 mr-3" data-tauri-drag-region>
      <div
        class="w-4 h-4 rounded bg-indigo-600 flex items-center justify-center shadow-sm"
      >
        <Zap size={10} fill="white" class="text-white" />
      </div>
      <span
        class="text-[11px] font-bold text-[var(--vscode-titleBar-activeForeground)] opacity-80 tracking-tight"
        >ETHER</span
      >
    </div>

    <!-- Menu Slot (Pass in buttons from parent) -->
    <div class="flex items-center h-full pointer-events-auto">
      {@render children?.()}
    </div>
  </div>

  <!-- Right Section: Status & Window Controls -->
  <div class="flex items-center h-full" data-tauri-drag-region>
    <!-- Theme Toggle -->
    <button
      class="h-full w-10 hover:bg-white/10 text-[var(--vscode-titleBar-activeForeground)] opacity-60 transition-colors flex items-center justify-center cursor-default z-50 pointer-events-auto mr-1"
      onclick={toggleTheme}
      title="Toggle Theme"
    >
      <SunMoon size={16} strokeWidth={1.5} />
    </button>

    <!-- Native Badge -->
    <div
      class="px-2 py-0.5 rounded bg-base-200 text-emerald-500 text-[9px] font-mono mr-2 border border-emerald-500/20 shadow-sm pointer-events-none"
    >
      NATIVE: ZIG
    </div>

    <!-- Controls (Only show if in Tauri) -->
    {#if appWindow}
      <button
        class="h-full w-12 hover:bg-white/10 text-[var(--vscode-titleBar-activeForeground)] transition-colors flex items-center justify-center cursor-default z-50 pointer-events-auto"
        onclick={minimize}
        title="Minimize"
      >
        <svg
          width="10"
          height="10"
          viewBox="0 0 16 16"
          fill="currentColor"
          class="w-2.5 h-2.5 opacity-80"
        >
          <path d="M14 8v1H2V8h12z" />
        </svg>
      </button>

      <button
        class="h-full w-12 hover:bg-white/10 text-[var(--vscode-titleBar-activeForeground)] transition-colors flex items-center justify-center cursor-default z-50 pointer-events-auto"
        onclick={toggleMaximize}
        title="Maximize"
      >
        <svg
          width="10"
          height="10"
          viewBox="0 0 16 16"
          fill="currentColor"
          class="w-2.5 h-2.5 opacity-80"
        >
          <path d="M3 3v10h10V3H3zm9 9H4V4h8v8z" />
        </svg>
      </button>

      <button
        class="h-full w-12 hover:bg-red-500 hover:text-white text-[var(--vscode-titleBar-activeForeground)] transition-colors flex items-center justify-center cursor-default z-50 pointer-events-auto"
        onclick={close}
        title="Close"
      >
        <svg
          width="10"
          height="10"
          viewBox="0 0 16 16"
          fill="currentColor"
          class="w-3 h-3 opacity-80"
        >
          <path
            d="M7.116 8l-4.558 4.558.884.884L8 8.884l4.558 4.558.884-.884L8.884 8l4.558-4.558-.884-.884L8 7.116 3.442 2.558l-.884.884L7.116 8z"
          />
        </svg>
      </button>
    {/if}
  </div>
</div>
