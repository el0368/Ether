<script>
  let { active_sidebar = 'files', live } = $props();
  let current_sidebar = $state(active_sidebar);
  let sidebar_visible = $state(true);

  function handleSetSidebar(id) {
    current_sidebar = id;
    sidebar_visible = true;
    if (live) live.pushEvent("set_sidebar", { panel: id });
  }
</script>

<div class="h-screen w-screen flex flex-col bg-[#1e1e1e] text-[#cccccc] font-sans">
  <div class="flex-1 flex overflow-hidden">
    <!-- Placeholder Activity Bar -->
    <div class="w-[48px] bg-[#333333] flex flex-col items-center py-4 gap-4">
      <button 
        class="w-8 h-8 rounded hover:bg-[#ffffff1a] {current_sidebar === 'files' ? 'text-white' : 'text-[#858585]'}"
        onclick={() => handleSetSidebar('files')}
      >📁</button>
      <button 
        class="w-8 h-8 rounded hover:bg-[#ffffff1a] {current_sidebar === 'search' ? 'text-white' : 'text-[#858585]'}"
        onclick={() => handleSetSidebar('search')}
      >🔍</button>
    </div>

    <!-- Placeholder Sidebar -->
    {#if sidebar_visible}
      <div class="w-[260px] bg-[#252526] border-r border-[#2b2b2b] p-4">
        <h2 class="text-[11px] font-bold uppercase mb-4">{current_sidebar}</h2>
        <div class="text-[12px] text-[#858585]">Ready for V2 implementation...</div>
      </div>
    {/if}

    <!-- Placeholder Editor -->
    <div class="flex-1 flex flex-col items-center justify-center">
      <div class="text-[20px] font-bold text-[#333333] select-none">ETHER V2</div>
      <div class="text-[12px] text-[#444444]">Clean Surface | Industrial Core</div>
    </div>
  </div>
</div>
