<script>
    import { onMount, tick } from "svelte";

    let { 
        isOpen = false, 
        items = [], 
        x = 0, 
        y = 0, 
        onClose,
        onAction
    } = $props();

    let menuElement = $state(null);

    function handleClickOutside(e) {
        if (menuElement && !menuElement.contains(e.target)) {
            onClose?.();
        }
    }

    $effect(() => {
        if (isOpen) {
            window.addEventListener('mousedown', handleClickOutside);
            adjustPosition();
        } else {
            window.removeEventListener('mousedown', handleClickOutside);
        }
    });

    async function adjustPosition() {
        await tick();
        if (!menuElement) return;
        
        const rect = menuElement.getBoundingClientRect();
        const winWidth = window.innerWidth;
        const winHeight = window.innerHeight;

        // Flip to fit screen
        if (x + rect.width > winWidth) x = winWidth - rect.width - 5;
        if (y + rect.height > winHeight) y = winHeight - rect.height - 5;
    }

    function handleAction(item) {
        if (item.separator) return;
        onAction?.(item);
        onClose?.();
    }
</script>

{#if isOpen}
    <div 
        bind:this={menuElement}
        class="context-menu"
        style="left: {x}px; top: {y}px;"
    >
        <ul class="menu-list">
            {#each items as item}
                {#if item.separator}
                    <li class="menu-separator"></li>
                {:else}
                    <!-- svelte-ignore a11y_click_events_have_key_events -->
                    <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
                    <li 
                        class="menu-item" 
                        class:disabled={item.disabled}
                        onclick={() => handleAction(item)}
                    >
                        <span class="item-label">{item.label}</span>
                        {#if item.keybinding}
                            <span class="item-keybinding">{item.keybinding}</span>
                        {/if}
                    </li>
                {/if}
            {/each}
        </ul>
    </div>
{/if}

<style>
    .context-menu {
        position: fixed;
        z-index: 2000;
        background-color: var(--vscode-menu-background);
        color: var(--vscode-menu-foreground);
        border: 1px solid var(--vscode-menu-border, rgba(255, 255, 255, 0.1));
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.4);
        padding: 4px 0;
        min-width: 160px;
        user-select: none;
    }

    .menu-list {
        list-style: none;
        padding: 0;
        margin: 0;
    }

    .menu-item {
        display: flex;
        align-items: center;
        padding: 4px 12px;
        cursor: pointer;
        font-size: 13px;
        gap: 20px;
    }

    .menu-item:hover {
        background-color: var(--vscode-menu-selectionBackground);
        color: var(--vscode-menu-selectionForeground);
    }

    .menu-item.disabled {
        opacity: 0.4;
        cursor: default;
    }

    .item-label {
        flex: 1;
        white-space: nowrap;
    }

    .item-keybinding {
        font-size: 11px;
        opacity: 0.5;
    }

    .menu-separator {
        height: 1px;
        background-color: var(--vscode-menu-separatorBackground, rgba(255, 255, 255, 0.1));
        margin: 4px 0;
    }
</style>
