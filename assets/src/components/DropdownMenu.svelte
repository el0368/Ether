<script>
  import { onMount } from "svelte";

  let { label, items = [] } = $props();
  let isOpen = $state(false);
  let menuElement = $state(null);

  function toggle() {
    isOpen = !isOpen;
  }

  function close() {
    isOpen = false;
  }

  function handleItemClick(item) {
    if (item.action) item.action();
    close();
  }

  onMount(() => {
    function handleClickOutside(event) {
      if (menuElement && !menuElement.contains(event.target)) {
        close();
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  });
</script>

<div class="relative h-full pointer-events-auto" bind:this={menuElement}>
  <button
    class="h-full px-3 hover:bg-white/10 transition-colors text-[11px] opacity-70 text-[var(--vscode-titleBar-activeForeground)] cursor-default flex items-center"
    class:bg-white-10={isOpen}
    onclick={toggle}
  >
    {label}
  </button>

  {#if isOpen}
    <div
      class="absolute top-full left-0 mt-0.5 w-[260px] bg-[var(--vscode-menu-background)] text-[var(--vscode-menu-foreground)] border border-[var(--vscode-menu-border)] shadow-xl z-[1000] py-1 rounded-sm backdrop-blur-md"
    >
      {#each items as item}
        {#if item.separator}
          <div class="h-[1px] bg-white/10 my-1 mx-2"></div>
        {:else}
          <button
            class="w-full flex items-center justify-between px-2 py-1.5 hover:bg-[var(--vscode-menu-selectionBackground)] hover:text-[var(--vscode-menu-selectionForeground)] text-left group"
            onclick={() => handleItemClick(item)}
          >
            <div class="flex items-center gap-2 flex-1 min-w-0">
              <!-- Checkmark area -->
              <div class="w-4 h-4 flex items-center justify-center shrink-0">
                {#if item.checked}
                  <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" class="opacity-80"><polyline points="20 6 9 17 4 12"/></svg>
                {/if}
              </div>

              <!-- Label -->
              <span class="text-[11.5px] truncate flex-1">{item.label}</span>
            </div>

            <!-- Shortcut or Submenu -->
            <div class="flex items-center gap-2 pl-4 shrink-0">
              {#if item.shortcut}
                <span class="text-[11px] opacity-40 font-mono tracking-tighter group-hover:opacity-80">{item.shortcut}</span>
              {/if}
              {#if item.submenu}
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="opacity-40 group-hover:opacity-100"><polyline points="9 18 15 12 9 6"/></svg>
              {/if}
            </div>
          </button>
        {/if}
      {/each}
    </div>
  {/if}
</div>

<style>
  .bg-white-10 {
    background-color: rgba(255, 255, 255, 0.1);
    opacity: 1 !important;
  }
</style>
