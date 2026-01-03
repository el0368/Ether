<script>
    import MonacoEditor from "./MonacoEditor.svelte";

    let {
        editorGroups = $bindable(),
        activeGroupIndex = $bindable(),
        channel,
        onSplit,
        onCloseGroup,
    } = $props();

    // Derived
    // We don't necessarily need derived mainly for display loop

    function closeGroup(idx) {
        if (editorGroups.length > 1) {
            editorGroups.splice(idx, 1);
            activeGroupIndex = Math.min(
                activeGroupIndex,
                editorGroups.length - 1,
            );
        } else {
            editorGroups[0].file = null;
            editorGroups[0].content = "";
        }
    }
</script>

<div class="flex-1 flex overflow-hidden">
    {#each editorGroups as group, idx}
        <!-- Pane -->
        <div
            class="flex-1 flex flex-col min-w-0 border-r border-base-content/10 last:border-r-0 relative group/pane {idx ===
            activeGroupIndex
                ? 'bg-base-200'
                : 'opacity-80'}"
            onclick={() => (activeGroupIndex = idx)}
            role="button"
            tabindex="0"
            onkeydown={(e) => e.key === "Enter" && (activeGroupIndex = idx)}
        >
            <!-- Editor Tabs -->
            <div
                class="flex items-center bg-base-300 h-9 min-h-[2.25rem] overflow-x-auto no-scrollbar justify-between"
            >
                <div class="flex items-center h-full">
                    {#if group.file}
                        <div
                            class="flex items-center {idx === activeGroupIndex
                                ? 'bg-base-200 border-t border-t-primary'
                                : 'bg-base-300'} h-full px-4 gap-2 border-r border-black/20"
                        >
                            <span class="text-xs text-primary opacity-60"
                                >📄</span
                            >
                            <span
                                class="text-[13px] whitespace-nowrap text-base-content"
                                >{group.file.name}</span
                            >
                            <button
                                class="ml-2 opacity-20 hover:opacity-100 text-[10px]"
                                onclick={(e) => {
                                    e.stopPropagation();
                                    closeGroup(idx);
                                }}>✕</button
                            >
                        </div>
                    {/if}
                </div>

                <!-- Actions -->
                <div class="flex items-center px-2 gap-2">
                    <button
                        class="opacity-40 hover:opacity-100 text-xs p-1 hover:bg-white/5 rounded"
                        title="Split Editor Right"
                        onclick={(e) => {
                            e.stopPropagation();
                            onSplit();
                        }}>◫</button
                    >
                    <button
                        class="opacity-40 hover:opacity-100 text-xs p-1 hover:bg-white/5 rounded"
                        >•••</button
                    >
                </div>
            </div>

            <!-- Breadcrumbs -->
            {#if group.file}
                <div
                    class="h-6 flex items-center px-4 bg-base-200 border-b border-black/10 text-[11px] opacity-40 gap-1"
                >
                    <span>Aether</span>
                    <span>›</span>
                    <span class="font-bold"
                        >{group.file.path.split("/").join(" › ")}</span
                    >
                </div>
            {/if}

            <!-- Main Editor Area -->
            <section class="flex-1 flex flex-col bg-base-100 min-h-0 relative">
                {#if group.file}
                    <div class="flex-1 overflow-hidden relative h-full min-h-0">
                        {#if group.file.is_dir}
                            <div
                                class="flex h-full items-center justify-center text-white/10 bg-base-100"
                            >
                                <div class="text-center">
                                    <div
                                        class="text-8xl mb-4 font-black opacity-5"
                                    >
                                        📁
                                    </div>
                                </div>
                            </div>
                        {:else if !group.content && group.content !== ""}
                            <!-- Note: empty string content is valid, null/undefined usually means loading (or file opening) -->
                            <!-- But typical logic: if file is set but content is null, it's loading. If content is "", it's empty file. -->
                            <!-- We'll assume openFile sets content to string. -->
                            <!-- Original logic: !group.content matches empty string too if not careful. -->
                            <!-- Let's check logic: original was {:else if !group.content} loading -->
                            <!-- But wait, an empty file has content "". !"" is true. So empty file shows spinner? -->
                            <!-- We should probably check undefined/null specifically if we handled it that way. -->
                            <!-- In OpenFile: group.content = resp.content. If file empty, content is "". -->
                            <!-- Let's stick to original implementation for logic parity for now. -->
                            <!-- If group.content is "", it shows spinner in original? -->
                            <!-- Actually, let's fix that potential bug if it exists. -->
                            {#if group.content === null || group.content === undefined}
                                <div
                                    class="flex h-full items-center justify-center bg-base-100"
                                >
                                    <span
                                        class="loading loading-ring loading-lg text-primary opacity-20"
                                    ></span>
                                </div>
                            {:else}
                                <MonacoEditor
                                    value={group.content}
                                    path={group.file.path}
                                    {channel}
                                    onChange={(val) => {
                                        group.content = val;
                                    }}
                                />
                            {/if}
                        {/if}
                    </div>
                {:else}
                    <div
                        class="flex-1 flex items-center justify-center bg-base-200"
                    >
                        <div class="text-center opacity-20">
                            <span class="text-9xl">⚡</span>
                        </div>
                    </div>
                {/if}
            </section>
        </div>
    {/each}
</div>
