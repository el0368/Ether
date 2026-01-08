<script>
    import {
        ArrowLeftRight,
        Rss,
        ShieldCheck,
        Bell,
        Cpu,
        Info,
    } from "lucide-svelte";
    let { nifPulse, activeFile } = $props();
</script>

<footer
    class="h-[22px] min-h-[22px] bg-[var(--vscode-statusBar-background)] text-[var(--vscode-statusBar-foreground)] flex items-center px-3 text-[11px] justify-between border-t border-[var(--vscode-statusBar-border)] transition-colors duration-300"
    style:background-color={nifPulse ? "#10b981" : "var(--vscode-statusBar-background)"}
>
    <!-- Left Section -->
    <div class="flex items-center h-full">
        <div
            class="flex items-center h-full px-2 gap-1 bg-white/10 cursor-pointer hover:bg-white/20"
        >
            <ArrowLeftRight size={13} />
            <span class="font-bold">elemental</span>
        </div>

        <div
            class="flex items-center h-full px-3 gap-1.5 hover:bg-white/10 cursor-pointer"
        >
            <Rss size={13} strokeWidth={1.5} />
            <span>main*</span>
        </div>

        <div
            class="flex items-center h-full px-3 gap-1.5 hover:bg-white/10 cursor-pointer border-r border-white/5"
        >
            <Cpu size={13} strokeWidth={1.5} class={nifPulse ? "animate-pulse" : ""} />
            <span class="font-medium tracking-tight">NATIVE: ZIG</span>
        </div>

        <div
            class="flex items-center h-full px-3 gap-1.5 hover:bg-white/10 cursor-pointer"
        >
            <ShieldCheck size={13} strokeWidth={1.5} />
            <span>Trusted</span>
        </div>
    </div>

    <!-- Right Section -->
    <div class="flex items-center h-full">
        <div
            class="flex items-center h-full px-3 gap-1.5 hover:bg-white/10 cursor-pointer"
        >
            <span class="opacity-80">Line 1, Col 1</span>
        </div>

        <div
            class="flex items-center h-full px-3 gap-1.5 hover:bg-white/10 cursor-pointer"
        >
            <span class="opacity-80">UTF-8</span>
        </div>

        <div
            class="flex items-center h-full px-3 gap-1.5 hover:bg-white/10 cursor-pointer"
        >
            {#if activeFile}
                <span class="opacity-90">{activeFile.name.split(".").pop() === "ex"
                    ? "Elixir"
                    : activeFile.name.split(".").pop().toUpperCase()}</span>
            {:else}
                <span class="opacity-90">Plain Text</span>
            {/if}
        </div>

        <div
            class="flex items-center h-full px-2 hover:bg-white/10 cursor-pointer"
        >
            <Bell size={13} strokeWidth={1.5} />
        </div>
    </div>
</footer>
