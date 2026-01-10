<script>
  import { ChevronRight, ChevronDown, FileCode, Folder, MoreHorizontal } from 'lucide-svelte';
  
  let { files = [], active_file = null, live } = $props();

  function selectFile(path) {
    live.pushEvent("select_file", { path });
  }

  // Group files into a tree structure if not already flat
  // Actually, Ether seems to stream them.
  // We might want to handle the flat list and build a local tree or just render flat with indentation.
</script>

<div class="flex-1 overflow-y-auto overflow-x-hidden py-1 select-none">
  {#each files as file}
    <div
      role="button"
      tabindex="0"
      onclick={() => selectFile(file.path)}
      class="flex items-center gap-1.5 px-3 py-0.5 cursor-pointer hover:bg-[#2a2d2e] transition-colors duration-75 group {active_file?.path === file.path ? 'bg-[#37373d] text-white' : 'text-[#cccccc]'}"
      style="padding-left: {file.depth * 16 + 12}px"
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
