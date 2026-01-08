<script>
    import {
        Files,
        Search,
        GitBranch,
        Play,
        GraduationCap,
        UserCircle,
        Settings,
    } from "lucide-svelte";
    let { activeSidebar, sidebarVisible, onToggle } = $props();
</script>

<nav
    class="w-[48px] bg-[var(--vscode-activityBar-background)] flex flex-col items-center py-2 gap-0 shrink-0 border-r border-[var(--vscode-activityBar-border)]"
>
    <div class="flex flex-col w-full">
        <!-- Explorer -->
        <button
            data-testid="activity-explorer"
            class="h-12 w-full flex items-center justify-center transition-all cursor-pointer relative {activeSidebar ===
                'files' && sidebarVisible
                ? 'text-[var(--vscode-activityBar-foreground)]'
                : 'text-[var(--vscode-activityBar-inactiveForeground)] hover:text-[var(--vscode-activityBar-foreground)]'}"
            title="Explorer"
            onclick={() => onToggle("files")}
        >
            {#if activeSidebar === "files" && sidebarVisible}
                <div
                    class="absolute left-0 top-0 bottom-0 w-[2px] bg-[var(--vscode-activityBar-activeBorder)]"
                ></div>
            {/if}
            <Files size={24} strokeWidth={1.5} />
        </button>

        <!-- Search -->
        <button
            class="h-12 w-full flex items-center justify-center transition-all cursor-pointer relative {activeSidebar ===
                'search' && sidebarVisible
                ? 'text-[var(--vscode-activityBar-foreground)]'
                : 'text-[var(--vscode-activityBar-inactiveForeground)] hover:text-[var(--vscode-activityBar-foreground)]'}"
            title="Search"
            onclick={() => onToggle("search")}
        >
            {#if activeSidebar === "search" && sidebarVisible}
                <div
                    class="absolute left-0 top-0 bottom-0 w-[2px] bg-[var(--vscode-activityBar-activeBorder)]"
                ></div>
            {/if}
            <Search size={24} strokeWidth={1.5} />
        </button>

        <!-- Source Control -->
        <button
            class="h-12 w-full flex items-center justify-center transition-all cursor-pointer relative {activeSidebar ===
                'git' && sidebarVisible
                ? 'text-[var(--vscode-activityBar-foreground)]'
                : 'text-[var(--vscode-activityBar-inactiveForeground)] hover:text-[var(--vscode-activityBar-foreground)]'}"
            title="Source Control"
            onclick={() => onToggle("git")}
        >
            {#if activeSidebar === "git" && sidebarVisible}
                <div
                    class="absolute left-0 top-0 bottom-0 w-[2px] bg-[var(--vscode-activityBar-activeBorder)]"
                ></div>
            {/if}
            <GitBranch size={24} strokeWidth={1.5} />
        </button>

        <!-- Debug -->
        <button
            class="h-12 w-full flex items-center justify-center transition-all cursor-pointer relative {activeSidebar ===
                'debug' && sidebarVisible
                ? 'text-[var(--vscode-activityBar-foreground)]'
                : 'text-[var(--vscode-activityBar-inactiveForeground)] hover:text-[var(--vscode-activityBar-foreground)]'}"
            title="Run and Debug"
            onclick={() => onToggle("debug")}
        >
            {#if activeSidebar === "debug" && sidebarVisible}
                <div
                    class="absolute left-0 top-0 bottom-0 w-[2px] bg-[var(--vscode-activityBar-activeBorder)]"
                ></div>
            {/if}
            <Play size={24} strokeWidth={1.5} />
        </button>

        <!-- Academy -->
        <button
            class="h-12 w-full flex items-center justify-center transition-all cursor-pointer relative {activeSidebar ===
                'academy' && sidebarVisible
                ? 'text-[var(--vscode-activityBar-foreground)]'
                : 'text-[var(--vscode-activityBar-inactiveForeground)] hover:text-[var(--vscode-activityBar-foreground)]'}"
            title="Academy Studio"
            onclick={() => onToggle("academy")}
        >
            {#if activeSidebar === "academy" && sidebarVisible}
                <div
                    class="absolute left-0 top-0 bottom-0 w-[2px] bg-[var(--vscode-activityBar-activeBorder)]"
                ></div>
            {/if}
            <GraduationCap size={24} strokeWidth={1.5} />
        </button>
    </div>

    <!-- Bottom Actions -->
    <div class="mt-auto flex flex-col w-full">
        <button
            class="h-12 w-full flex items-center justify-center text-[var(--vscode-activityBar-inactiveForeground)] hover:text-[var(--vscode-activityBar-foreground)] transition-colors"
        >
            <UserCircle size={24} strokeWidth={1.5} />
        </button>
        <button
            class="h-12 w-full flex items-center justify-center text-[var(--vscode-activityBar-inactiveForeground)] hover:text-[var(--vscode-activityBar-foreground)] transition-colors"
        >
            <Settings size={24} strokeWidth={1.5} />
        </button>
    </div>
</nav>
