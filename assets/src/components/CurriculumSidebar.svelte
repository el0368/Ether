<script>
    import { ChevronDown, Map, BookOpen, FileText } from "lucide-svelte";
    let { files = [], onOpenFile } = $props();

    // Helper to group files by grade
    let grades = $derived(() => {
        const map = {};
        files.forEach(f => {
            if (f.path.includes('/academy/')) {
                const parts = f.path.split('/academy/')[1].split('/');
                if (parts.length > 1) {
                    const grade = parts[0];
                    if (!map[grade]) map[grade] = [];
                    map[grade].push(f);
                }
            }
        });
        return Object.entries(map).map(([name, items]) => ({ name, items }));
    });
</script>

<div class="curriculum-explorer h-full overflow-y-auto text-xs flex flex-col">
    {#each grades() as grade}
        <div class="grade-section">
            <div class="px-2 py-1 flex items-center gap-1.5 bg-[var(--vscode-sideBarSectionHeader-background)] border-b border-[var(--vscode-sideBarSectionHeader-border)] font-bold uppercase tracking-tight text-[11px] text-[var(--vscode-sideBarTitle-foreground)]">
                <ChevronDown size={14} class="opacity-60" />
                <BookOpen size={14} class="text-blue-400/60" />
                <span class="ml-1">{grade.name}</span>
            </div>
            <div class="grade-content py-1">
                {#each grade.items as item}
                    <button 
                        class="w-full text-left px-8 py-1.5 hover:bg-[var(--vscode-list-hoverBackground)] cursor-pointer truncate flex items-center gap-2 group transition-colors"
                        onclick={() => onOpenFile(item)}
                    >
                        <FileText size={14} class="opacity-40 group-hover:opacity-100" />
                        <span class="opacity-80 group-hover:opacity-100">{item.name}</span>
                    </button>
                {/each}
            </div>
        </div>
    {/each}
</div>

<style>
    .grade-section {
        border-bottom: 1px solid var(--vscode-sideBar-border);
    }
</style>
