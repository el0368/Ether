<script>
    let { channel, onSelectFile } = $props();

    let query = $state("");
    let results = $state([]);
    let searching = $state(false);

    function handleSearch() {
        if (!query.trim() || !channel) return;

        searching = true;
        channel
            .push("search:global", { query: query.trim() })
            .receive("ok", (resp) => {
                results = resp.results || [];
                searching = false;
            })
            .receive("error", () => {
                searching = false;
            });
    }

    function handleKeydown(e) {
        if (e.key === "Enter") {
            handleSearch();
        }
    }

    // Group by file
    let groupedResults = $derived(() => {
        const groups = {};
        results.forEach((res) => {
            if (!groups[res.path]) groups[res.path] = [];
            groups[res.path].push(res);
        });
        return groups;
    });
</script>

<div class="flex flex-col h-full bg-[var(--vscode-sideBar-background)] text-[var(--vscode-sideBar-foreground)]">
    <div class="p-3">
        <div class="relative flex items-center mb-2">
            <input
                type="text"
                placeholder="Search"
                class="w-full bg-[var(--vscode-input-background)] border border-[var(--vscode-input-border)] px-2 py-1 text-sm outline-none focus:border-[var(--vscode-focusBorder)] text-[var(--vscode-input-foreground)]"
                bind:value={query}
                onkeydown={handleKeydown}
            />
            {#if searching}
                <div class="absolute right-2">
                    <span class="loading loading-spinner loading-xs opacity-40"
                    ></span>
                </div>
            {/if}
        </div>

        <div
            class="flex gap-2 opacity-40 text-[10px] uppercase font-bold tracking-tight"
        >
            <span>Files to include</span>
        </div>
    </div>

    <div class="flex-1 overflow-auto py-2">
        {#if results.length === 0 && !searching && query}
            <div class="p-8 text-center opacity-30 italic text-sm">
                No results found
            </div>
        {:else}
            {#each Object.entries(groupedResults()) as [path, matches]}
                <div class="mb-2">
                    <div
                        class="flex items-center px-4 py-1 gap-1 hover:bg-[var(--vscode-list-hoverBackground)] cursor-pointer opacity-80"
                        onclick={() =>
                            onSelectFile({ path, name: path.split("/").pop() })}
                    >
                        <span class="text-[10px]">▼</span>
                        <span class="text-xs truncate">{path}</span>
                        <span
                            class="ml-auto text-[10px] bg-[var(--vscode-focusBorder)]/20 text-[var(--vscode-focusBorder)] px-1 rounded-sm"
                            >{matches.length}</span
                        >
                    </div>
                    <div class="pl-8">
                        {#each matches as match}
                            <button
                                class="w-full text-left px-2 py-1 hover:bg-[var(--vscode-list-hoverBackground)] text-[11px] truncate opacity-60 flex items-center gap-2 group border-l border-transparent hover:border-[var(--vscode-focusBorder)] transition-all font-mono"
                                onclick={() =>
                                    onSelectFile({
                                        path: match.path,
                                        name: match.path.split("/").pop(),
                                    })}
                            >
                                <span
                                    class="text-[var(--vscode-focusBorder)]/40 font-bold w-4 shrink-0"
                                    >{match.line}</span
                                >
                                <span class="truncate">{match.content}</span>
                            </button>
                        {/each}
                    </div>
                </div>
            {/each}
        {/if}
    </div>
</div>
