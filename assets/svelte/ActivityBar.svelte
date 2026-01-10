<script>
  import { Files, Search, GitBranch, Settings, FlaskConical, Command } from 'lucide-svelte';
  
  let { active_sidebar, sidebar_visible, pinned_containers = [], onToggleHeader, live } = $props();

  function setSidebar(id) {
    live.pushEvent("set_sidebar", { panel: id });
  }

  function toggleSidebar() {
    live.pushEvent("toggle_sidebar", {});
  }
</script>

<div class="w-[50px] min-w-[50px] bg-[#333333] flex flex-col items-center py-2 select-none border-r border-[#2b2b2b] z-20">
  <div class="flex flex-col gap-2 w-full items-center">
    {#each pinned_containers as container}
      <button
        onclick={() => active_sidebar === container.id ? onToggleHeader() : setSidebar(container.id)}
        class="p-3 cursor-pointer transition-colors duration-150 relative group {active_sidebar === container.id && sidebar_visible ? 'text-white' : 'text-[#858585] hover:text-[#cccccc]'}"
        title={container.label}
      >
        {#if active_sidebar === container.id && sidebar_visible}
          <div class="absolute left-0 top-0 bottom-0 w-0.5 bg-white"></div>
        {/if}
        
        {#if container.id === 'files'}
          <Files size={24} />
        {:else if container.id === 'search'}
          <Search size={24} />
        {:else if container.id === 'git'}
          <GitBranch size={24} />
        {:else if container.id === 'testing'}
          <FlaskConical size={24} />
        {:else}
          <Command size={24} />
        {/if}
      </button>
    {/each}
  </div>

  <div class="mt-auto flex flex-col gap-2 w-full items-center mb-2">
    <button class="p-3 cursor-pointer text-[#858585] hover:text-[#cccccc] transition-colors" title="Settings">
      <Settings size={24} />
    </button>
  </div>
</div>
