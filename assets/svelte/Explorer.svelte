<script>
  import { ChevronRight, ChevronDown, FileCode, Folder, FolderOpen, RefreshCw } from 'lucide-svelte';
  import { open } from '@tauri-apps/plugin-dialog';
  
  let { files = [], active_file = null, is_loading = false, live } = $props();

  async function openFolder() {
    try {
      const selected = await open({
        directory: true,
        multiple: false,
        title: "Select Project Folder"
      });
      
      if (selected) {
        live.pushEvent("open_folder_path", { path: selected });
      }
    } catch (e) {
      // Fallback for non-Tauri environment
      live.pushEvent("open_folder", {});
    }
  }

  function selectFile(path) {
    live.pushEvent("select_file", { path });
  }

  function refreshFolder() {
    live.pushEvent("refresh_folder", {});
  }
</script>

<div class="flex-1 flex flex-col overflow-hidden">
  {#if files.length === 0 && !is_loading}
    <!-- Empty state with Open Folder button -->
    <div class="flex-1 flex flex-col items-center justify-center gap-4 p-4">
      <p class="text-[12px] text-[#858585] text-center">
        You have not yet opened a folder.
      </p>
      <button
        onclick={openFolder}
        class="px-4 py-2 bg-[#0e639c] hover:bg-[#1177bb] text-white text-[13px] rounded transition-colors"
      >
        Open Folder
      </button>
    </div>
  {:else}
    <!-- File tree -->
    <div class="flex-1 overflow-y-auto overflow-x-hidden py-1 select-none">
      {#if is_loading}
        <div class="flex items-center justify-center py-4">
          <RefreshCw size={16} class="animate-spin text-[#858585]" />
          <span class="ml-2 text-[12px] text-[#858585]">Scanning...</span>
        </div>
      {/if}
      
      {#each files as file}
        <div
          role="button"
          tabindex="0"
          onclick={() => selectFile(file.path)}
          onkeydown={(e) => e.key === 'Enter' && selectFile(file.path)}
          class="flex items-center gap-1.5 px-3 py-0.5 cursor-pointer hover:bg-[#2a2d2e] transition-colors duration-75 group {active_file?.path === file.path ? 'bg-[#37373d] text-white' : 'text-[#cccccc]'}"
          style="padding-left: {(file.depth || 0) * 16 + 12}px"
        >
          {#if file.type === 'directory'}
            <ChevronRight size={16} class="text-[#858585]" />
            <Folder size={16} class="text-[#cccccc]" />
          {:else}
            <div class="w-4"></div>
            <FileCode size={16} class="text-[#cccccc]" />
          {/if}
          <span class="text-[13px] truncate flex-1">{file.name}</span>
        </div>
      {/each}
    </div>
  {/if}
</div>
