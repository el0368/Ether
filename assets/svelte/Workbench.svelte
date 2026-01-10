<script>
  import ActivityBar from './ActivityBar.svelte';
  import Explorer from './Explorer.svelte';
  import Editor from './Editor.svelte';
  import { MoreHorizontal } from 'lucide-svelte';

  let { 
    active_sidebar, 
    sidebar_visible: initial_sidebar_visible, 
    workbench_layout = { containers: [], pinned_ids: [] }, 
    active_file, 
    file_count, 
    is_loading, 
    files = [], 
    editor_content = "",
    live 
  } = $props();


  let sidebar_visible = $state(initial_sidebar_visible);
  let current_sidebar = $state(active_sidebar);

  // Guard against server race conditions
  let last_interaction_time = 0;

  function handleToggleSidebar() {
    last_interaction_time = Date.now();
    sidebar_visible = !sidebar_visible;
    live.pushEvent("toggle_sidebar", { visible: sidebar_visible });
  }

  function handleSetSidebar(id) {
    last_interaction_time = Date.now();
    
    if (current_sidebar === id) {
      if (sidebar_visible) {
        // Toggle off if clicking active
        sidebar_visible = false;
        live.pushEvent("toggle_sidebar", { visible: false });
      } else {
        // Toggle on if clicking hidden active
        sidebar_visible = true;
        live.pushEvent("toggle_sidebar", { visible: true });
      }
    } else {
      current_sidebar = id;
      sidebar_visible = true;
      live.pushEvent("set_sidebar", { panel: id });
    }
  }

  // Derived state for the active panel
  let active_container = $derived(
    workbench_layout?.containers?.find(c => c.id === current_sidebar) || 
    { id: 'files', label: 'Explorer' }
  );

  let previous_active_sidebar = active_sidebar; // Track the last prop value we processed

  $effect(() => {
    // Only update local state if:
    // 1. The PROP has actually changed
    // 2. We haven't clicked recently (Guard against server Ack race condition)
    if (active_sidebar !== previous_active_sidebar) {
      previous_active_sidebar = active_sidebar;
      
      const time_since_interaction = Date.now() - last_interaction_time;
      if (time_since_interaction > 500) {
        current_sidebar = active_sidebar;
        sidebar_visible = initial_sidebar_visible; // Sync visibility strictly from server? No, dangerous.
      } else {
        console.log("Ignored stale server update (Race Condition Guard)");
      }
    }
  });

  // Sync visibility prop separately but loosely
  $effect(() => {
    if (initial_sidebar_visible !== sidebar_visible) {
       const time_since_interaction = Date.now() - last_interaction_time;
       if (time_since_interaction > 500) {
          sidebar_visible = initial_sidebar_visible;
       }
    }
  });
</script>

<div class="h-screen w-screen flex flex-col bg-[#1e1e1e] text-[#cccccc] overflow-hidden font-sans">
  <div class="flex-1 flex min-h-0 overflow-hidden">
    <ActivityBar 
      active_sidebar={current_sidebar} 
      {sidebar_visible}
      onToggleHeader={handleToggleSidebar} 
      onSetSidebar={handleSetSidebar}
      pinned_containers={workbench_layout?.containers?.filter(c => workbench_layout.pinned_ids.includes(c.id)) || []}
      {live}
    />

    {#if sidebar_visible}
      <div class="w-[var(--vscode-sidebar-width,260px)] min-w-[260px] bg-[#252526] border-r border-[#2b2b2b] flex flex-col relative overflow-hidden">
        <div class="px-4 flex items-center justify-between h-[35px] min-h-[35px] text-[11px] font-bold uppercase tracking-wider text-[#bbbbbb] select-none">
          <span>{active_container.label}</span>
          <div class="flex items-center gap-2">
            <MoreHorizontal size={16} class="cursor-pointer hover:bg-[#ffffff1a] rounded" />
          </div>
        </div>
        
        <div class="flex-1 overflow-y-auto">
          <div class={active_container.id === 'files' ? 'h-full block' : 'hidden'}>
            <Explorer {files} {active_file} {live} />
          </div>
          
          {#if active_container.id !== 'files'}
            <div class="flex-1 flex items-center justify-center text-[12px] text-[#858585] italic h-full">
              {active_container.label} functionality coming soon...
            </div>
          {/if}
        </div>
      </div>
    {/if}

    <div class="flex-1 flex flex-col min-w-0">
      <Editor {active_file} content={editor_content} {live} />
    </div>
  </div>
</div>

<style>
  :global(:root) {
    --vscode-sidebar-width: 260px;
  }
</style>
