<script>
    let { isOpen, items = [], onSelect, onClose } = $props();

    let query = $state("");
    let selectedIndex = $state(0);
    let container;

    let filteredItems = $derived(() => {
        if (!query) return items;
        return items
            .filter((item) =>
                item.name.toLowerCase().includes(query.toLowerCase()),
            )
            .slice(0, 10);
    });

    function handleKeydown(e) {
        if (e.key === "Escape") {
            onClose();
        } else if (e.key === "ArrowDown") {
            selectedIndex = (selectedIndex + 1) % filteredItems().length;
        } else if (e.key === "ArrowUp") {
            selectedIndex =
                (selectedIndex - 1 + filteredItems().length) %
                filteredItems().length;
        } else if (e.key === "Enter") {
            if (filteredItems().length > 0) {
                onSelect(filteredItems()[selectedIndex]);
            }
        }
    }

    $effect(() => {
        if (isOpen) {
            setTimeout(() => {
                const input = document.getElementById("command-palette-input");
                if (input) input.focus();
            }, 50);
        }
    });
</script>

{#if isOpen}
    <!-- Overlay -->
    <div
        class="fixed inset-0 bg-black/50 z-50 flex justify-center pt-8"
        onclick={onClose}
    >
        <!-- Palette -->
        <div
            class="w-full max-w-xl bg-[#252526] border border-white/10 shadow-2xl rounded-md flex flex-col h-fit max-h-[400px] overflow-hidden"
            onclick={(e) => e.stopPropagation()}
        >
            <div class="p-2 border-b border-white/5">
                <input
                    id="command-palette-input"
                    type="text"
                    placeholder="Type a file name or command..."
                    class="w-full bg-[#3c3c3c] text-white border-none outline-none px-4 py-2 text-sm"
                    bind:value={query}
                    onkeydown={handleKeydown}
                />
            </div>

            <div class="flex-1 overflow-auto py-1">
                {#each filteredItems() as item, idx}
                    <div
                        class="px-4 py-1.5 flex items-center gap-3 cursor-pointer text-sm {idx ===
                        selectedIndex
                            ? 'bg-primary text-white'
                            : 'hover:bg-white/5 text-[#cccccc]'}"
                        onclick={() => onSelect(item)}
                    >
                        <span class="opacity-40"
                            >{item.is_dir ? "📁" : "📄"}</span
                        >
                        <div class="flex flex-col">
                            <span class="font-medium">{item.name}</span>
                            <span class="text-[10px] opacity-40"
                                >{item.path}</span
                            >
                        </div>
                    </div>
                {/each}
                {#if filteredItems().length === 0}
                    <div class="p-8 text-center opacity-30 text-xs italic">
                        No matching results
                    </div>
                {/if}
            </div>

            <div
                class="p-2 bg-[#1e1e1e] border-t border-white/5 flex justify-end gap-2 text-[10px] opacity-40 uppercase font-black"
            >
                <span>↑↓ to navigate</span>
                <span>↵ to select</span>
                <span>esc to dismiss</span>
            </div>
        </div>
    </div>
{/if}
