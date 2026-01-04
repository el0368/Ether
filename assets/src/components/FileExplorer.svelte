<script>
    // Removed lucide-svelte due to Svelte 5 Runes incompatibility ($$props error)
    // Using inline SVGs for stability

    // Svelte 5 Runes
    let {
        files = [],
        isLoading = false,
        activeFile = null,
        onOpenFile = () => {},
    } = $props();

    const skeletons = Array(15).fill(0);

    function handleFileClick(file) {
        if (file.type !== "directory") {
            onOpenFile(file);
        }
        // Directory expansion logic would go here if implemented
    }
</script>

<div class="flex flex-col h-full w-full overflow-y-auto">
    <div
        class="p-2 text-[10px] font-bold opacity-50 uppercase tracking-widest flex justify-between items-center bg-base-300/50 sticky top-0 z-10 backdrop-blur-md"
    >
        <span>Explorer</span>
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
                class="animate-spin text-primary"
                ><path d="M21 12a9 9 0 1 1-6.219-8.56" /></svg
            >
        {/if}
    </div>

    <div class="flex flex-col gap-0.5 mt-2">
        {#if files.length === 0 && isLoading}
            <!-- 🦴 Skeleton Screen: Immediate feedback -->
            {#each skeletons as _}
                <div class="flex items-center gap-2 px-3 py-1.5 animate-pulse">
                    <div class="w-4 h-4 bg-white/5 rounded"></div>
                    <div class="h-2.5 bg-white/5 rounded w-2/3"></div>
                </div>
            {/each}
        {:else if files.length === 0 && !isLoading}
            <div class="px-4 py-8 text-center opacity-30 text-[11px] italic">
                No files found
            </div>
        {:else}
            <!-- Live File List -->
            {#each files as file}
                <!-- svelte-ignore a11y_click_events_have_key_events -->
                <!-- svelte-ignore a11y_no_static_element_interactions -->
                <div
                    class="flex items-center gap-2 px-3 py-1 hover:bg-white/5 cursor-pointer group transition-colors {activeFile &&
                    activeFile.path === file.path
                        ? 'bg-primary/10 text-primary'
                        : ''}"
                    onclick={() => handleFileClick(file)}
                >
                    {#if file.type === "directory" || file.type === 2 || file.type === "dir"}
                        <!-- Folder -->
                        <svg
                            xmlns="http://www.w3.org/2000/svg"
                            width="14"
                            height="14"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            class="text-primary/70 fill-primary/10"
                            ><path
                                d="M4 20h16a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.93a2 2 0 0 1-1.66-.9l-.82-1.2A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13c0 1.1.9 2 2 2Z"
                            /></svg
                        >
                    {:else}
                        <!-- File -->
                        <svg
                            xmlns="http://www.w3.org/2000/svg"
                            width="14"
                            height="14"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            class="opacity-40"
                            ><path
                                d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"
                            /><path d="M14 2v4a2 2 0 0 0 2 2h4" /></svg
                        >
                    {/if}
                    <span
                        class="text-[12px] truncate opacity-80 group-hover:opacity-100"
                        >{file.name}</span
                    >
                </div>
            {/each}
        {/if}
    </div>
</div>
