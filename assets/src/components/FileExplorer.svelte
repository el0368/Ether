<script>
    import { keybindings } from "../lib/state/keybindings.svelte";
    import { buildTree, toggleNodeExpansion } from "../lib/utils/tree";
    import Tree from "../lib/components/ui/Tree.svelte";

    let {
        files = [],
        isLoading = false,
        activeFile = null,
        onOpenFile = () => {},
        onExpand = () => {},
        onNewFile = () => {},
        onNewFolder = () => {},
        onRefresh = () => {},
        onOpenProjectFolder = () => {},
    } = $props();

    // Maintain local expanded state on top of the tree structure
    let expandedPaths = $state(new Set());

    let nestedTree = $derived.by(() => {
        const rawTree = buildTree(files);
        // Apply expanded state to the tree
        const applyExpanded = (nodes) => {
            for (const node of nodes) {
                if (expandedPaths.has(node.path)) {
                    node.expanded = true;
                }
                if (node.children && node.children.length > 0) {
                    applyExpanded(node.children);
                }
            }
        };
        applyExpanded(rawTree);
        return rawTree;
    });


    function handleFocus() {
        keybindings.setContext("explorer");
    }


    function handleToggle(item) {
        if (expandedPaths.has(item.path)) {
            expandedPaths.delete(item.path);
        } else {
            expandedPaths.add(item.path);
            onExpand(item);
        }
        // Trigger reactivity
        expandedPaths = new Set(expandedPaths);
    }
</script>

<!-- svelte-ignore a11y_no_static_element_interactions -->
<div class="flex flex-col h-full w-full" onmousedown={handleFocus}>
    <div
        class="group p-2 text-[10px] font-bold text-[var(--vscode-sideBarTitle-foreground)] uppercase tracking-widest flex justify-between items-center bg-[var(--vscode-sideBar-background)] flex-none z-10 backdrop-blur-md border-b border-[var(--vscode-sideBar-border)]"
    >
        <span>Explorer</span>
        <div class="flex items-center gap-1">
            {#if isLoading}
                <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="12"
                    height="12"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    class="animate-spin text-[var(--vscode-focusBorder)] mr-1"
                    ><path d="M21 12a9 9 0 1 1-6.219-8.56" /></svg
                >
            {/if}
            
            <button class="opacity-40 hover:opacity-100 p-0.5" onclick={onNewFile} title="New File">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"/><path d="M14 2v4a2 2 0 0 0 2 2h4"/><path d="M9 15h6"/><path d="M12 12v6"/></svg>
            </button>
            <button class="opacity-40 hover:opacity-100 p-0.5" onclick={onNewFolder} title="New Folder">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.93a2 2 0 0 1-1.66-.9l-.82-1.2A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13c0 1.1.9 2 2 2Z"/><path d="M12 10v6"/><path d="M9 13h6"/></svg>
            </button>
            <button class="opacity-40 hover:opacity-100 p-0.5" onclick={onRefresh} title="Refresh">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8"/><path d="M21 3v5h-5"/><path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16"/><path d="M3 21v-5h5"/></svg>
            </button>
        </div>
    </div>

    <div class="flex-1 overflow-y-auto w-full">
        {#if files.length === 0 && !isLoading}
            <div class="flex flex-col items-center justify-center p-8 text-center h-full">
                <p class="text-[12px] opacity-60 mb-4">You have not yet opened a folder.</p>
                <button 
                    onclick={onOpenProjectFolder}
                    class="px-4 py-2 bg-[var(--vscode-button-background)] hover:bg-[var(--vscode-button-hoverBackground)] text-[var(--vscode-button-foreground)] text-[12px] rounded transition-colors font-medium"
                >
                    Open Folder
                </button>
            </div>
        {:else}
            <Tree 
                items={nestedTree} 
                activeItem={activeFile} 
                onSelect={onOpenFile} 
                onToggle={handleToggle} 
            />
        {/if}
    </div>
</div>
