<script>
    import { NifDecoder } from "../lib/nif_decoder";

    let { fileTree = [], activeFile = null, onOpenFile } = $props();

    // Virtualization State
    let container;
    let scrollTop = $state(0);
    let viewportHeight = $state(0);
    const itemHeight = 24; // Fixed height per item (px)
    const buffer = 10; // Extra items to render

    // Derived Virtual State
    let totalHeight = $derived(fileTree.length * itemHeight);
    let startIndex = $derived(Math.floor(scrollTop / itemHeight));
    let endIndex = $derived(
        Math.min(
            fileTree.length,
            Math.floor((scrollTop + viewportHeight) / itemHeight) + buffer,
        ),
    );

    let visibleItems = $derived(
        fileTree.slice(Math.max(0, startIndex - buffer), endIndex),
    );

    let offsetY = $derived(Math.max(0, startIndex - buffer) * itemHeight);

    function handleScroll(e) {
        scrollTop = e.target.scrollTop;
    }

    // Resize Observer to update viewport height
    $effect(() => {
        if (container) {
            const ro = new ResizeObserver((entries) => {
                viewportHeight = entries[0].contentRect.height;
            });
            ro.observe(container);
            return () => ro.disconnect();
        }
    });

    // Handle File Icon
    function getIcon(file) {
        if (file.type === "directory") return "📁";
        if (file.type === "symlink") return "🔗";
        return "📄";
    }
</script>

<div
    bind:this={container}
    class="flex-1 overflow-auto relative w-full h-full"
    onscroll={handleScroll}
>
    <!-- Phantom Container for Scrollbar -->
    <div style="height: {totalHeight}px; position: relative;">
        <!-- Windowed Content -->
        <div
            style="transform: translateY({offsetY}px); position: absolute; top: 0; width: 100%;"
        >
            {#if fileTree.length === 0}
                <div class="p-6 flex flex-col items-center gap-2 opacity-30">
                    <span class="loading loading-spinner loading-xs"></span>
                </div>
            {:else}
                <ul class="menu menu-xs p-0 gap-0 w-full">
                    {#each visibleItems as file (file.path)}
                        <li class="group w-full block h-[24px]">
                            <button
                                class="rounded-none px-4 w-full text-left transition-all text-base-content hover:text-white hover:bg-white/[0.05] border-l-2 border-transparent text-[13px] gap-2 items-center flex h-[24px] min-h-[24px]"
                                class:active-file={activeFile === file}
                                onclick={() => onOpenFile(file)}
                            >
                                <span
                                    class="text-xs opacity-40 shrink-0 w-4 text-center"
                                >
                                    {getIcon(file)}
                                </span>
                                <span class="truncate">{file.name}</span>
                            </button>
                        </li>
                    {/each}
                </ul>
            {/if}
        </div>
    </div>
</div>

<style>
    .active-file {
        background-color: #37373d !important;
        color: white !important;
        border-left-color: #007acc !important;
    }
</style>
