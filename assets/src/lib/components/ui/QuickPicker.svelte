<script>
    import VscodeIcon from "./VscodeIcon.svelte";
    import { fuzzyFilter } from "../../utils/fuzzy";

    let {
        isOpen,
        items = [],
        recentFiles = [],
        symbols = [],
        mode = "files",
        onSelect,
        onClose,
    } = $props();

    let query = $state("");
    let selectedIndex = $state(0);
    let inputBatch = $state(null);

    let filteredItems = $derived.by(() => {
        const q = query.trim();
        if (mode === "symbols") {
            const results = fuzzyFilter(q, symbols);
            return results.slice(0, 25);
        }

        // Files Mode
        if (!q) {
            const recent = recentFiles.map(f => ({ ...f, isRecent: true }));
            return [...recent, ...items].slice(0, 20);
        }

        const results = fuzzyFilter(q, items);
        return results.slice(0, 20);
    });

    function handleKeydown(e) {
        if (e.key === "Escape") {
            onClose();
        } else if (e.key === "ArrowDown") {
            selectedIndex = (selectedIndex + 1) % filteredItems.length;
        } else if (e.key === "ArrowUp") {
            selectedIndex = (selectedIndex - 1 + filteredItems.length) % filteredItems.length;
        } else if (e.key === "Enter") {
            if (filteredItems.length > 0) {
                onSelect(filteredItems[selectedIndex]);
            }
        }
    }

    $effect(() => {
        if (isOpen) {
            selectedIndex = 0;
            query = "";
            setTimeout(() => {
                inputBatch?.focus();
            }, 20);
        }
    });

    function getIcon(item) {
        if (item.kind === "function") return "symbol-method";
        if (item.kind === "module") return "symbol-namespace";
        if (item.is_dir) return "folder";
        return "file";
    }
</script>

{#if isOpen}
    <!-- Overlay -->
    <!-- svelte-ignore a11y_no_static_element_interactions -->
    <div
        class="quick-input-overlay"
        onclick={onClose}
    >
        <!-- Palette Container -->
        <div
            class="quick-input-widget"
            onclick={(e) => e.stopPropagation()}
        >
            <div class="quick-input-header">
                <div class="quick-input-filter">
                    <input
                        bind:this={inputBatch}
                        type="text"
                        placeholder="Type a file name or command..."
                        class="quick-input-input"
                        bind:value={query}
                        onkeydown={handleKeydown}
                    />
                </div>
            </div>

            <div class="quick-input-list">
                {#each filteredItems as item, idx}
                    <div
                        class="quick-input-item"
                        class:active={idx === selectedIndex}
                        role="option"
                        tabindex="0"
                        aria-selected={idx === selectedIndex}
                        onclick={() => onSelect(item)}
                    >
                        <div class="item-icon">
                            <VscodeIcon name={getIcon(item)} size={16} />
                        </div>
                        <div class="item-label">
                            <span class="label-name">{item.name}</span>
                            <span class="label-description">{item.path}</span>
                        </div>
                        {#if item.isRecent}
                            <div class="item-meta">
                                <VscodeIcon name="history" size={14} />
                            </div>
                        {/if}
                    </div>
                {/each}
                
                {#if filteredItems.length === 0}
                    <div class="quick-input-empty">
                        No matching results
                    </div>
                {/if}
            </div>
        </div>
    </div>
{/if}

<style>
    .quick-input-overlay {
        position: fixed;
        inset: 0;
        z-index: 1000;
        display: flex;
        justify-content: center;
        padding-top: 8px;
        background-color: transparent;
    }

    .quick-input-widget {
        width: 600px;
        background-color: var(--vscode-quickInput-background);
        color: var(--vscode-quickInput-foreground);
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.4);
        border: 1px solid var(--vscode-widget-border, rgba(255, 255, 255, 0.1));
        display: flex;
        flex-direction: column;
        max-height: 500px;
        overflow: hidden;
    }

    .quick-input-header {
        padding: 6px 6px 0 6px;
    }

    .quick-input-filter {
        display: flex;
        align-items: center;
    }

    .quick-input-input {
        width: 100%;
        background-color: var(--vscode-input-background);
        color: var(--vscode-input-foreground);
        border: 1px solid var(--vscode-input-border, transparent);
        outline: none;
        padding: 4px 8px;
        font-size: 13px;
    }

    .quick-input-input:focus {
        border-color: var(--vscode-focusBorder);
    }

    .quick-input-list {
        flex: 1;
        overflow-y: auto;
        padding: 6px 0;
    }

    .quick-input-item {
        display: flex;
        align-items: center;
        padding: 4px 12px;
        gap: 10px;
        cursor: pointer;
        font-size: 13px;
        user-select: none;
    }

    .quick-input-item.active {
        background-color: var(--vscode-list-activeSelectionBackground);
        color: var(--vscode-list-activeSelectionForeground);
    }

    .item-icon {
        display: flex;
        align-items: center;
        opacity: 0.8;
    }

    .quick-input-item.active .item-icon {
        opacity: 1;
    }

    .item-label {
        display: flex;
        flex-direction: column;
        flex: 1;
        overflow: hidden;
    }

    .label-name {
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .label-description {
        font-size: 11px;
        opacity: 0.6;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .quick-input-item.active .label-description {
        opacity: 0.8;
    }

    .item-meta {
        opacity: 0.4;
    }

    .quick-input-empty {
        padding: 20px;
        text-align: center;
        opacity: 0.4;
        font-style: italic;
        font-size: 12px;
    }
</style>
