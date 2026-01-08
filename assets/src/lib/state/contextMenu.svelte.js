/* Context Menu State Rune for Ether */

class ContextMenuState {
    isOpen = $state(false);
    x = $state(0);
    y = $state(0);
    items = $state([]);
    onAction = null;

    show(x, y, items, onAction) {
        this.x = x;
        this.y = y;
        this.items = items;
        this.onAction = onAction;
        this.isOpen = true;
    }

    close() {
        this.isOpen = false;
    }
}

export const contextMenu = new ContextMenuState();
