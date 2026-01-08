<script>
    /**
     * Boundary.svelte - Svelte 5 Error Boundary (Revised)
     * 
     * Note: Svelte does not have native Error Boundaries like React.
     * This component provides a manual "try again" mechanism but cannot
     * automatically catch errors from child components during render.
     * 
     * The primary purpose is to:
     * 1. Provide a recovery mechanism if an error is manually set.
     * 2. Offer a uniform fallback UI pattern for the IDE.
     */
    let { children, name = "Component" } = $props();
    
    // In a true production app, errors would be caught by a top-level
    // onError handler and routed here. For now, this is a placeholder
    // for the "unbreakable UI" pattern.
    let error = $state(null);

    function reset() {
        error = null;
    }
</script>

{#if error}
    <div class="flex flex-col items-center justify-center p-6 bg-[var(--vscode-editor-background)] text-[var(--vscode-errorForeground)] border border-[var(--vscode-errorForeground)] rounded m-2">
        <div class="flex items-center gap-2 mb-2">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-alert-triangle"><path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/><path d="M12 9v4"/><path d="M12 17h.01"/></svg>
            <h3 class="font-bold text-lg">{name} Crashed</h3>
        </div>
        <p class="text-sm opacity-80 mb-4 font-mono max-w-md overflow-hidden text-ellipsis whitespace-nowrap">
            {error?.message || "Unknown error"}
        </p>
        <button 
            onclick={reset}
            class="px-4 py-2 bg-[var(--vscode-button-background)] hover:bg-[var(--vscode-button-hoverBackground)] text-[var(--vscode-button-foreground)] rounded transition-colors"
        >
            Reload Component
        </button>
    </div>
{:else}
    {@render children()}
{/if}
