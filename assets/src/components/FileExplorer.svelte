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
        class="p-2 text-[10px] font-bold opacity-50 uppercase tracking-widest flex justify-between items-center bg-base-300/50 flex-none z-10 backdrop-blur-md"
    >
        <span>Explorer ({files.length})</span>
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
            <div class="px-4 py-8 text-center opacity-30 text-[11px] italic">
                No files found
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
                            class="flex items-center gap-2 px-3 hover:bg-white/5 cursor-pointer group transition-colors box-border"
                            style="height: {ROW_HEIGHT}px; padding-left: {(file.name.split(
                                '/',
                            ).length -
                                1) *
                                12 +
                                12}px"
                            class:bg-primary-10={activeFile &&
                                activeFile.path === file.path}
                            class:text-primary={activeFile &&
                                activeFile.path === file.path}
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
                                    class="text-primary/70 fill-primary/10 shrink-0"
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
                                    class="opacity-40 shrink-0"
                                    ><path
                                        d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"
                                    /><path d="M14 2v4a2 2 0 0 0 2 2h4" /></svg
                                >
                            {/if}
                            <span
                                class="text-[12px] truncate opacity-80 group-hover:opacity-100"
                                >{file.name.split("/").pop()}</span
                            >
                        </div>
                    {/each}
                </div>
            </div>
        {/if}
    </div>
</div>
