/* Keybinding & Focus Service for Ether */

class KeybindingService {
    activeContext = $state("editor"); // explorer, editor, palette, etc.
    keyMap = new Map();

    constructor() {
        if (typeof window !== 'undefined') {
            window.addEventListener('keydown', (e) => this.handleKeyDown(e), true);
        }
    }

    setContext(context) {
        this.activeContext = context;
        console.log("Focus Context Switch:", context);
    }

    register(context, key, action) {
        if (!this.keyMap.has(context)) {
            this.keyMap.set(context, new Map());
        }
        this.keyMap.get(context).set(key, action);
    }

    handleKeyDown(e) {
        const key = this.getShortcutString(e);
        
        // 1. Global / Priority bindings
        if (key === "ctrl+p") {
            e.preventDefault();
            this.triggerGlobal("open_quick_picker");
            return;
        }

        // 2. Context-specific bindings
        if (this.keyMap.has(this.activeContext)) {
            const contextMap = this.keyMap.get(this.activeContext);
            if (contextMap.has(key)) {
                e.preventDefault();
                contextMap.get(key)(e);
                return;
            }
        }
    }

    getShortcutString(e) {
        const parts = [];
        if (e.ctrlKey || e.metaKey) parts.push("ctrl");
        if (e.shiftKey) parts.push("shift");
        if (e.altKey) parts.push("alt");
        
        const keyName = e.key.toLowerCase();
        if (!["control", "shift", "alt", "meta"].includes(keyName)) {
            parts.push(keyName);
        }
        
        return parts.join("+");
    }

    triggerGlobal(id) {
        console.log("Global Trigger:", id);
        // This would connect to the UI state (e.g., ui.showQuickPicker = true)
    }
}

export const keybindings = new KeybindingService();
