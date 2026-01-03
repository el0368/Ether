<script>
    let { nifPulse, activeFile } = $props();
</script>

<footer
    class="h-6 bg-[#007acc] flex items-center px-4 text-[11px] text-white shrink-0 justify-between transition-colors duration-300"
    class:bg-emerald-600={nifPulse}
>
    <div class="flex items-center gap-4">
        <div
            class="flex items-center gap-1 hover:bg-white/10 px-2 h-full cursor-pointer"
        >
            <span>{nifPulse ? "⚡" : "🌿"}</span>
            <span class="font-medium">elemental*</span>
        </div>
        <div class="flex items-center gap-2">
            <span>⊗ 0</span>
            <span>⚠ 0</span>
        </div>
    </div>
    <div class="flex items-center gap-4">
        <div class="opacity-80">Line 1, Col 1</div>
        <div class="opacity-80">UTF-8</div>
        <div class="px-2 hover:bg-white/10 cursor-pointer">
            {#if activeFile}
                {activeFile.name.split(".").pop() === "ex"
                    ? "Elixir"
                    : activeFile.name.split(".").pop().toUpperCase()}
            {:else}
                Plain Text
            {/if}
        </div>
        <div class="flex items-center gap-1">
            <span>🔔</span>
        </div>
    </div>
</footer>
