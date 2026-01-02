<script>
    let { channel } = $props();

    let branches = $state([]);
    let currentBranch = $state("main");
    let status = $state([]);

    $effect(() => {
        if (channel) {
            channel.push("git:status", {}).receive("ok", (resp) => {
                status = resp.files || [];
                currentBranch = resp.branch || "main";
            });
        }
    });
</script>

<div class="p-4 text-sm">
    <div class="flex items-center gap-2 mb-4">
        <span class="text-[#569cd6]">⎇</span>
        <span class="font-semibold">{currentBranch}</span>
    </div>

    {#if status.length === 0}
        <p class="opacity-50">No changes</p>
    {:else}
        <div class="space-y-1">
            {#each status as file}
                <div
                    class="flex items-center gap-2 hover:bg-white/5 px-2 py-1 rounded"
                >
                    <span class="text-green-400">M</span>
                    <span class="truncate">{file}</span>
                </div>
            {/each}
        </div>
    {/if}
</div>
