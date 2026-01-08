<script>
    import VscodeIcon from "./VscodeIcon.svelte";
    import { contextMenu } from "../../state/contextMenu.svelte";

    let { 
        items = [], 
        onSelect, 
        activeItem = null,
        onToggle,
        depth = 0
    } = $props();

    function handleToggle(item, e) {
        e.stopPropagation();
        onToggle?.(item);
    }

    function handleSelect(item) {
        onSelect?.(item);
    }

    function handleContextMenu(item, e) {
        e.preventDefault();
        e.stopPropagation();
        
        const menuItems = [
            { label: "New File", keybinding: "Ctrl+N", action: "new_file" },
            { label: "New Folder", action: "new_folder" },
            { separator: true },
            { label: "Cut", keybinding: "Ctrl+X", action: "cut" },
            { label: "Copy", keybinding: "Ctrl+C", action: "copy" },
            { label: "Paste", keybinding: "Ctrl+V", action: "paste" },
            { separator: true },
            { label: "Rename...", keybinding: "F2", action: "rename" },
            { label: "Delete", keybinding: "Del", action: "delete" },
        ];

        contextMenu.show(e.clientX, e.clientY, menuItems, (actionItem) => {
            console.log("Tree Action:", actionItem.action, "on", item.path);
            // Bubbling up actions would be handled by a higher-level state or event
        });
    }

    function handleDragStart(item, e) {
        e.dataTransfer.setData("application/ether-node", JSON.stringify(item));
        e.dataTransfer.effectAllowed = "move";
    }

    function handleDragOver(item, e) {
        if (!item.is_dir) return; // Only folders are drop targets for now
        e.preventDefault();
        e.dataTransfer.dropEffect = "move";
        e.currentTarget.classList.add("drop-target");
    }

    function handleDragLeave(e) {
        e.currentTarget.classList.remove("drop-target");
    }

    function handleDrop(item, e) {
        e.preventDefault();
        e.currentTarget.classList.remove("drop-target");
        
        const data = e.dataTransfer.getData("application/ether-node");
        if (data) {
            const draggedItem = JSON.parse(data);
            if (draggedItem.path === item.path) return;
            console.log("Move", draggedItem.path, "into", item.path);
            // This would trigger a move action in the explorer state
        }
    }

    function getIcon(item) {
        if (item.is_dir) {
            return item.expanded ? "folder-opened" : "folder";
        }
        return "file";
    }
</script>

<ul class="tree-container" style="--depth: {depth}">
    {#each items as item}
        <li class="tree-node" class:selected={activeItem?.path === item.path}>
            <!-- svelte-ignore a11y_click_events_have_key_events -->
            <!-- svelte-ignore a11y_no_static_element_interactions -->
            <div 
                class="node-content" 
                draggable="true"
                onclick={() => handleSelect(item)}
                oncontextmenu={(e) => handleContextMenu(item, e)}
                ondragstart={(e) => handleDragStart(item, e)}
                ondragover={(e) => handleDragOver(item, e)}
                ondragleave={handleDragLeave}
                ondrop={(e) => handleDrop(item, e)}
                style="padding-left: {depth * 12 + 8}px"
            >
                <div 
                    class="node-twistie" 
                    class:expanded={item.expanded}
                    class:hidden={!item.is_dir}
                    onclick={(e) => handleToggle(item, e)}
                >
                    <VscodeIcon name="chevron-right" size={16} />
                </div>
                
                <div class="node-icon">
                    <VscodeIcon name={getIcon(item)} size={16} />
                </div>

                <span class="node-label">{item.name}</span>
            </div>

            {#if item.is_dir && item.expanded && item.children}
                <svelte:self 
                    items={item.children} 
                    depth={depth + 1} 
                    {onSelect} 
                    {activeItem} 
                    {onToggle} 
                />
            {/if}
        </li>
    {/each}
</ul>

<style>
    .tree-container {
        list-style: none;
        padding: 0;
        margin: 0;
        user-select: none;
    }

    .tree-node {
        display: flex;
        flex-direction: column;
    }

    .node-content {
        display: flex;
        align-items: center;
        height: 22px;
        cursor: pointer;
        gap: 6px;
        font-size: 13px;
        color: var(--vscode-sideBar-foreground);
    }

    .node-content:hover, .node-content.drop-target {
        background-color: var(--vscode-list-hoverBackground);
    }

    .tree-node.selected > .node-content {
        background-color: var(--vscode-list-activeSelectionBackground);
        color: var(--vscode-list-activeSelectionForeground);
    }

    .node-twistie {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 16px;
        height: 16px;
        transition: transform 0.1s ease-in-out;
        opacity: 0.6;
    }

    .node-twistie.expanded {
        transform: rotate(90deg);
    }

    .node-twistie.hidden {
        visibility: hidden;
    }

    .node-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        opacity: 0.8;
    }

    .node-label {
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        flex: 1;
    }
</style>
