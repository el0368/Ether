<script>
    import FileExplorer from "./FileExplorer.svelte";
    import GitPanel from "./GitPanel.svelte";
    import SearchPanel from "./SearchPanel.svelte";
    import CurriculumSidebar from "./CurriculumSidebar.svelte";
    import { ChevronDown, ChevronRight, MoreHorizontal } from "lucide-svelte";

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
        onNewFile,
        onNewFolder,
        onRefresh,
        onOpenProjectFolder,
    } = $props();
</script>

{#if sidebarVisible}
    <aside
        class="w-64 bg-[var(--vscode-sideBar-background)] border-r border-[var(--vscode-sideBar-border)] flex flex-col overflow-hidden shrink-0"
    >
        <div class="p-[10px] pl-[20px] pr-[12px] flex items-center justify-between">
            <span
                class="text-[11px] font-medium uppercase tracking-wider text-[var(--vscode-sideBarTitle-foreground)]"
            >
                {#if activeSidebar === "files"}Explorer
                {:else if activeSidebar === "git"}Source Control
                {:else if activeSidebar === "academy"}Academy Studio
                {:else}{activeSidebar}{/if}
            </span>
            <button
                class="opacity-40 hover:opacity-100 hover:bg-white/10 rounded p-1"
                onclick={onMenuClick}
            >
                <MoreHorizontal size={16} />
            </button>
        </div>

        <!-- Content Area -->
        <div class="flex-1 overflow-hidden flex flex-col">
            {#if activeSidebar === "files"}
                <div
                    class="flex items-center px-1 py-1 bg-[var(--vscode-sideBarSectionHeader-background)] gap-1 cursor-pointer border-t border-b border-[var(--vscode-sideBarSectionHeader-border)]"
                >
                    <span class="text-[16px] opacity-80 ml-1">
                        <ChevronDown size={14} />
                    </span>
                    <span
                        class="text-[11px] font-bold uppercase tracking-tight text-[var(--vscode-sideBarTitle-foreground)]"
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
                        {onNewFile}
                        {onNewFolder}
                        {onRefresh}
                        {onOpenProjectFolder}
                    />
                </div>
            {:else if activeSidebar === "git"}
                <div class="p-4">
                    <GitPanel {channel} />
                </div>
            {:else if activeSidebar === "search"}
                <SearchPanel {channel} onSelectFile={onOpenFile} />
            {:else if activeSidebar === "academy"}
                <div
                    class="flex items-center px-1 py-1 bg-white/[0.03] gap-1 cursor-pointer border-b border-[var(--vscode-sideBar-border)]"
                >
                    <span class="text-[10px] opacity-40 ml-1">▼</span>
                    <span
                        class="text-[11px] font-bold uppercase tracking-tight text-[var(--vscode-sideBarTitle-foreground)]"
                        >Academy Curriculum</span
                    >
                </div>
                <!-- TODO: Create AcademyExplorer for grade-based navigation -->
                <div class="flex-1 overflow-hidden">
                    <CurriculumSidebar files={fileTree} {onOpenFile} />
                </div>
            {:else}
                <div class="p-8 text-center opacity-20 italic text-sm">
                    Section arriving soon...
                </div>
            {/if}
        </div>

        <!-- Collapsible: Outline (Placeholder) -->
        <div class="bg-white/2 border-t border-[var(--vscode-sideBar-border)]">
            <div
                class="flex items-center px-1 py-1 gap-1 cursor-pointer hover:bg-[var(--vscode-list-hoverBackground)] bg-[var(--vscode-sideBarSectionHeader-background)] border-b border-[var(--vscode-sideBarSectionHeader-border)]"
            >
                <span class="text-[16px] opacity-80 ml-1">
                    <ChevronRight size={14} />
                </span>
                <span
                    class="text-[11px] font-bold uppercase tracking-tight text-[var(--vscode-sideBarTitle-foreground)]"
                    >Outline</span
                >
            </div>
        </div>

        <!-- Collapsible: Timeline (Placeholder) -->
        <div class="bg-white/2 border-t border-[var(--vscode-sideBar-border)]">
            <div
                class="flex items-center px-4 py-1 gap-1 cursor-pointer hover:bg-[var(--vscode-list-hoverBackground)]"
            >
                <span class="text-[10px] opacity-40">▶</span>
                <span
                    class="text-[11px] font-bold uppercase tracking-tight text-[var(--vscode-sideBarTitle-foreground)]"
                    >Timeline</span
                >
            </div>
        </div>
    </aside>
{/if}
