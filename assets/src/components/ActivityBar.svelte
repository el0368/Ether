<script>
    let { activeSidebar, sidebarVisible, onToggle } = $props();
</script>

<nav
    class="w-12 bg-base-300 flex flex-col items-center py-2 gap-2 shrink-0 border-r border-white/[0.03]"
>
    <div class="flex flex-col gap-1 w-full">
        <button
            class="h-12 w-full flex items-center justify-center transition-all cursor-pointer text-xl border-l-[3px] {activeSidebar ===
                'files' && sidebarVisible
                ? 'border-white opacity-100 bg-white/5'
                : 'border-transparent opacity-40 hover:opacity-80'}"
            title="Explorer"
            onclick={() => onToggle("files")}>📁</button
        >
        <button
            class="h-12 w-full flex items-center justify-center transition-all cursor-pointer text-xl border-l-[3px] {activeSidebar ===
                'git' && sidebarVisible
                ? 'border-white opacity-100 bg-white/5'
                : 'border-transparent opacity-40 hover:opacity-80'}"
            title="Source Control"
            onclick={() => onToggle("git")}>🌿</button
        >
        <button
            class="h-12 w-full flex items-center justify-center transition-all cursor-pointer text-xl border-l-[3px] {activeSidebar ===
                'search' && sidebarVisible
                ? 'border-white opacity-100 bg-white/5'
                : 'border-transparent opacity-40 hover:opacity-80'}"
            title="Search"
            onclick={() => onToggle("search")}>🔍</button
        >
        <button
            class="h-12 w-full flex items-center justify-center transition-all cursor-pointer text-xl border-l-[3px] {activeSidebar ===
                'debug' && sidebarVisible
                ? 'border-white opacity-100 bg-white/5'
                : 'border-transparent opacity-40 hover:opacity-80'}"
            title="Run and Debug"
            onclick={() => onToggle("debug")}>▶️</button
        >
    </div>
    <div class="mt-auto flex flex-col gap-4 opacity-40 pb-4">
        <button class="text-lg hover:opacity-100 transition-opacity">👤</button>
        <button class="text-lg hover:opacity-100 transition-opacity">⚙️</button>
    </div>
</nav>
