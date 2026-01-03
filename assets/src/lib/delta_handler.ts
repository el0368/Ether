/**
 * Delta Handler - Handles incremental file tree updates
 * Receives filetree:delta events from the backend and updates the UI
 */

export interface FileTreeItem {
    name: string;
    type: 'file' | 'directory' | 'symlink' | 'unknown';
    path: string;
}

export interface DeltaEvent {
    path: string;
    type: 'add' | 'remove' | 'modify' | 'rename' | 'unknown';
}

/**
 * Apply a delta event to a file tree
 * Returns a new array (immutable update)
 */
export function applyDelta(
    tree: FileTreeItem[],
    delta: DeltaEvent
): FileTreeItem[] {
    const normalizedPath = delta.path.replace(/\\/g, '/');
    const fileName = normalizedPath.split('/').pop() || normalizedPath;

    switch (delta.type) {
        case 'add':
            // Check if already exists
            if (tree.some(item => item.path === normalizedPath)) {
                return tree; // Already exists, no change
            }
            // Determine type from path (heuristic: no extension = directory)
            const isDir = !fileName.includes('.') && !fileName.startsWith('.');
            return [
                ...tree,
                {
                    name: fileName,
                    type: isDir ? 'directory' : 'file',
                    path: normalizedPath
                }
            ].sort((a, b) => {
                // Directories first, then alphabetical
                if (a.type === 'directory' && b.type !== 'directory') return -1;
                if (a.type !== 'directory' && b.type === 'directory') return 1;
                return a.name.localeCompare(b.name);
            });

        case 'remove':
            return tree.filter(item => !item.path.startsWith(normalizedPath));

        case 'modify':
            // For modify, we just need to ensure UI refreshes - no structural change needed
            return [...tree];

        case 'rename':
            // Full refresh needed for rename (we'd need old+new path)
            return tree;

        default:
            return tree;
    }
}

/**
 * Create a debounced delta processor
 * Batches rapid-fire events into single updates
 */
export function createDeltaBatcher(
    callback: (deltas: DeltaEvent[]) => void,
    delay: number = 100
): (delta: DeltaEvent) => void {
    let pending: DeltaEvent[] = [];
    let timeoutId: ReturnType<typeof setTimeout> | null = null;

    return (delta: DeltaEvent) => {
        pending.push(delta);

        if (timeoutId) {
            clearTimeout(timeoutId);
        }

        timeoutId = setTimeout(() => {
            callback([...pending]);
            pending = [];
            timeoutId = null;
        }, delay);
    };
}
