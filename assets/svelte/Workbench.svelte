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

  function handleToggleSidebar() {
    sidebar_visible = !sidebar_visible;
    live.pushEvent("toggle_sidebar", { visible: sidebar_visible });
  }

  // Derived state for the active panel
  let active_container = $derived(
    workbench_layout?.containers?.find(c => c.id === active_sidebar) || 
    { id: 'files', label: 'Explorer' }
  );

  // Sync prop change back to state if server overrides
  $effect(() => {
    sidebar_visible = initial_sidebar_visible;
  });
</script>

<div class="h-screen w-screen flex flex-col bg-[#1e1e1e] text-[#cccccc] overflow-hidden font-sans">
  <div class="flex-1 flex min-h-0 overflow-hidden">
    <ActivityBar 
      {active_sidebar} 
      {sidebar_visible}
      onToggleHeader={handleToggleSidebar} 
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
          {#if active_container.id === 'files'}
            <Explorer {files} {active_file} {live} />
          {:else}
            <div class="flex-1 flex items-center justify-center text-[12px] text-[#858585] italic">
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
