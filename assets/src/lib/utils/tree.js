/**
 * Converts a flat list of items with 'path' properties into a nested tree structure.
 */
export function buildTree(flatItems) {
    const root = [];
    const map = new Map();

    // First pass: create nodes
    for (const item of flatItems) {
        const node = { 
            ...item, 
            children: [], 
            expanded: false 
        };
        map.set(item.path, node);
    }

    // Second pass: associate children
    for (const item of flatItems) {
        const node = map.get(item.path);
        const parts = item.path.split('/');
        
        if (parts.length === 1 || (parts.length === 2 && parts[0] === '.')) {
            root.push(node);
        } else {
            const parentPath = parts.slice(0, -1).join('/');
            const parent = map.get(parentPath);
            if (parent) {
                parent.children.push(node);
            } else {
                root.push(node);
            }
        }
    }

    // Sort: directories first, then alpha
    const sortNodes = (nodes) => {
        nodes.sort((a, b) => {
            if (a.is_dir && !b.is_dir) return -1;
            if (!a.is_dir && b.is_dir) return 1;
            return a.name.localeCompare(b.name);
        });
        for (const node of nodes) {
            if (node.children.length > 0) {
                sortNodes(node.children);
            }
        }
    };

    sortNodes(root);
    return root;
}

/**
 * Updates a specific node in the tree (e.g., toggles expansion)
 */
export function toggleNodeExpansion(tree, path) {
    const traverse = (nodes) => {
        for (const node of nodes) {
            if (node.path === path) {
                node.expanded = !node.expanded;
                return true;
            }
            if (node.children && traverse(node.children)) {
                return true;
            }
        }
        return false;
    };
    traverse(tree);
    return [...tree]; // Return new reference for Svelte reactivity
}
