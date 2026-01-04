<script>
    import FileExplorer from "./FileExplorer.svelte";
    import GitPanel from "./GitPanel.svelte";
    import SearchPanel from "./SearchPanel.svelte";

    let {
        activeSidebar,
        sidebarVisible,
        fileTree,
        activeFile,
        isLoading = false,
        channel,
        onOpenFile,
        onMenuClick,
        onExpand,
    } = $props();
</script>

{#if sidebarVisible}
    <aside
        class="w-64 bg-base-300 border-r border-black/20 flex flex-col overflow-hidden shrink-0"
    >
        <div class="p-3 pl-5 flex items-center justify-between">
            <span
                class="text-[11px] font-medium uppercase tracking-wider opacity-60"
            >
                {#if activeSidebar === "files"}Explorer
                {:else if activeSidebar === "git"}Source Control
                {:else}{activeSidebar}{/if}
            </span>
            <button
                class="opacity-40 hover:opacity-100 pr-2"
                onclick={onMenuClick}>•••</button
            >
        </div>

        <!-- Content Area -->
        <div class="flex-1 overflow-hidden flex flex-col">
            {#if activeSidebar === "files"}
                <div
                    class="flex items-center px-1 py-1 bg-white/[0.03] gap-1 cursor-pointer"
                >
                    <span class="text-[10px] opacity-40 ml-1">▼</span>
                    <span
                        class="text-[11px] font-bold uppercase tracking-tight opacity-70"
                        >Aether Project</span
                    >
                </div>

                <div class="flex-1 overflow-hidden flex flex-col">
                    <FileExplorer
                        files={fileTree}
                        {activeFile}
                        {isLoading}
                        {onOpenFile}
                        {onExpand}
                    />
                </div>
            {:else if activeSidebar === "git"}
                <div class="p-4">
                    <GitPanel {channel} />
                </div>
            {:else if activeSidebar === "search"}
                <SearchPanel {channel} onSelectFile={onOpenFile} />
            {:else}
                <div class="p-8 text-center opacity-20 italic text-sm">
                    Section arriving soon...
                </div>
            {/if}
        </div>

        <!-- Collapsible: Outline (Placeholder) -->
        <div class="bg-white/2 border-t border-black/20">
            <div
                class="flex items-center px-4 py-1 gap-1 cursor-pointer hover:bg-white/5"
            >
                <span class="text-[10px] opacity-40">▶</span>
                <span
                    class="text-[11px] font-bold uppercase tracking-tight opacity-60"
                    >Outline</span
                >
            </div>
        </div>

        <!-- Collapsible: Timeline (Placeholder) -->
        <div class="bg-white/2 border-t border-black/20">
            <div
                class="flex items-center px-4 py-1 gap-1 cursor-pointer hover:bg-white/5"
            >
                <span class="text-[10px] opacity-40">▶</span>
                <span
                    class="text-[11px] font-bold uppercase tracking-tight opacity-60"
                    >Timeline</span
                >
            </div>
        </div>
    </aside>
{/if}
