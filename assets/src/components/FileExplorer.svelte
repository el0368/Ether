<script>
    // Removed lucide-svelte due to Svelte 5 Runes incompatibility ($$props error)
    // Using inline SVGs for stability

    // Svelte 5 Runes
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

    const skeletons = Array(15).fill(0);

    // Virtualization Constants
    const ROW_HEIGHT = 28; // px
    const BUFFER = 10; // Extra items to render

    // Virtualization State
    let scrollTop = $state(0);
    let containerHeight = $state(0);

    // Derived Virtualization Metrics
    let totalHeight = $derived(files.length * ROW_HEIGHT);
    let startIndex = $derived(Math.floor(scrollTop / ROW_HEIGHT));
    // Ensure we don't go out of bounds
    // visibleCount depends on containerHeight, default 0 causes slice(0, 10)
    let visibleCount = $derived(
        Math.ceil(containerHeight / ROW_HEIGHT) + BUFFER,
    );
    let visibleFiles = $derived(
        files.slice(startIndex, startIndex + visibleCount),
    );
    let offsetY = $derived(startIndex * ROW_HEIGHT);

    function handleScroll(e) {
        scrollTop = e.currentTarget.scrollTop;
    }

    function handleFileClick(file) {
        if (file.type !== "directory") {
            onOpenFile(file);
        } else {
            onExpand(file);
        }
    }
</script>

<div class="flex flex-col h-full w-full">
    <div
        class="group p-2 text-[10px] font-bold text-[var(--vscode-sideBarTitle-foreground)] uppercase tracking-widest flex justify-between items-center bg-[var(--vscode-sideBar-background)] flex-none z-10 backdrop-blur-md border-b border-[var(--vscode-sideBar-border)]"
    >
        <span>Explorer ({files.length})</span>
        <div class="flex items-center gap-1">
            {#if isLoading}
                <!-- Loader2 -->
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
            
            <button class="opacity-0 group-hover:opacity-40 hover:!opacity-100 p-0.5" onclick={onNewFile} title="New File">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"/><path d="M14 2v4a2 2 0 0 0 2 2h4"/><path d="M9 15h6"/><path d="M12 12v6"/></svg>
            </button>
            <button class="opacity-0 group-hover:opacity-40 hover:!opacity-100 p-0.5" onclick={onNewFolder} title="New Folder">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.93a2 2 0 0 1-1.66-.9l-.82-1.2A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13c0 1.1.9 2 2 2Z"/><path d="M12 10v6"/><path d="M9 13h6"/></svg>
            </button>
            <button class="opacity-0 group-hover:opacity-40 hover:!opacity-100 p-0.5" onclick={onRefresh} title="Refresh">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8"/><path d="M21 3v5h-5"/><path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16"/><path d="M3 21v-5h5"/></svg>
            </button>
        </div>
    </div>

    <!-- Virtual Scroll Container -->
    <div
        class="flex-1 overflow-y-auto relative w-full"
        onscroll={handleScroll}
        bind:clientHeight={containerHeight}
    >
        {#if files.length === 0 && isLoading}
            <!-- 🦴 Skeleton Screen: Immediate feedback -->
            <div class="flex flex-col gap-0.5 mt-2">
                {#each skeletons as _}
                    <div
                        class="flex items-center gap-2 px-3 py-1.5 animate-pulse"
                    >
                        <div class="w-4 h-4 bg-white/5 rounded"></div>
                        <div class="h-2.5 bg-white/5 rounded w-2/3"></div>
                    </div>
                {/each}
            </div>
        {:else if files.length === 0 && !isLoading}
            <!-- VS Code-style "No Folder Opened" prompt -->
            <div class="flex flex-col items-center justify-center p-8 text-center">
                <p class="text-[12px] opacity-60 mb-4">
                    You have not yet opened a folder.
                </p>
                <button 
                    onclick={onOpenProjectFolder}
                    class="px-4 py-2 bg-[var(--vscode-button-background)] hover:bg-[var(--vscode-button-hoverBackground)] text-[var(--vscode-button-foreground)] text-[12px] rounded transition-colors font-medium"
                >
                    Open Folder
                </button>
            </div>
        {:else}
            <!-- Virtual Shim -->
            <div style="height: {totalHeight}px; position: relative;">
                <!-- Visible Slice -->
                <div
                    class="absolute top-0 left-0 w-full flex flex-col"
                    style="transform: translateY({offsetY}px);"
                >
                    {#each visibleFiles as file (file.path)}
                        <!-- svelte-ignore a11y_click_events_have_key_events -->
                        <!-- svelte-ignore a11y_no_static_element_interactions -->
                        <div
                            class="flex items-center h-[28px] px-2 hover:bg-[var(--vscode-list-hoverBackground)] cursor-pointer group transition-colors box-border relative"
                            style="padding-left: {(file.name.split('/').length - 1) * 12 + 12}px"
                            class:bg-[var(--vscode-list-activeSelectionBackground)]={activeFile && activeFile.path === file.path}
                            class:text-[var(--vscode-list-activeSelectionForeground)]={activeFile && activeFile.path === file.path}
                            onclick={() => handleFileClick(file)}
                        >
                            {#if activeFile && activeFile.path === file.path}
                                <div class="absolute left-0 top-0 bottom-0 w-[2px] bg-[var(--vscode-focusBorder)]"></div>
                            {/if}

                            <div class="flex items-center justify-center w-4 h-4 shrink-0 opacity-60">
                                {#if file.type === "directory" || file.type === 2 || file.type === "dir"}
                                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-blue-400/80 fill-current/10"><path d="m6 9 6 6 6-6"/></svg>
                                {:else}
                                    <div class="w-2"></div>
                                {/if}
                            </div>

                            <div class="flex items-center justify-center w-5 h-5 shrink-0">
                                {#if file.type === "directory" || file.type === 2 || file.type === "dir"}
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-blue-400/90 fill-current/10"><path d="M4 20h16a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.93a2 2 0 0 1-1.66-.9l-.82-1.2A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13c0 1.1.9 2 2 2Z"/></svg>
                                {:else}
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-gray-400/80"><path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"/><path d="M14 2v4a2 2 0 0 0 2 2h4"/></svg>
                                {/if}
                            </div>

                            <span class="text-[13px] truncate ml-1 opacity-90 group-hover:opacity-100">{file.name.split("/").pop()}</span>
                        </div>
                    {/each}
                </div>
            </div>
        {/if}
    </div>
</div>
