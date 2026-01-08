export class EditorState {
    groups = $state([{ file: null, content: "" }]);
    activeIndex = $state(0);
    autoSave = $state(false);

    activeGroup = $derived(this.groups[this.activeIndex]);

    // Tauri Native: Read file using Rust
    async openFile(file, channel) {
        this.activeGroup.file = file;
        this.activeGroup.content = ""; // Clear content while loading
        
        // Import TauriFS dynamically to avoid circular dependency issues if any
        // But since this is a class, we can just rely on global availability or pass it in.
        // For now, let's assume we import it at the top or check window.__TAURI__
        
        const isTauri = typeof window !== 'undefined' && '__TAURI__' in window;

        if (isTauri) {
             try {
                // Dynamic import to avoid build issues if not in Tauri (though this file is part of the bundle)
                const TauriFS = await import("../tauri_fs");
                const content = await TauriFS.readFile(file.path);
                this.activeGroup.content = content;
             } catch (e) {
                 console.error("Tauri Read Error:", e);
                 this.activeGroup.content = "Error reading file: " + e;
             }
        } else if (channel) {
            channel.push("editor:read", { path: file.path })
                .receive("ok", (resp) => {
                    this.activeGroup.content = resp.content;
                });
        }
    }

    newUntitled() {
        this.activeGroup.file = { name: "Untitled", path: "untitled", type: "file" };
        this.activeGroup.content = "";
    }

    splitEditor() {
        const current = this.activeGroup;
        this.groups.push({ file: current.file, content: current.content });
        this.activeIndex = this.groups.length - 1;
    }

    closeEditor(index) {
        if (this.groups.length > 1) {
            this.groups.splice(index, 1);
            if (this.activeIndex >= this.groups.length) {
                this.activeIndex = this.groups.length - 1;
            }
        } else {
            this.groups[0] = { file: null, content: "" };
        }
    }

    closeAll() {
        this.groups = [{ file: null, content: "" }];
        this.activeIndex = 0;
    }

    async save(channel) {
        const g = this.activeGroup;
        if (!g.file) return;

        const isTauri = typeof window !== 'undefined' && '__TAURI__' in window;

        if (isTauri) {
             try {
                const TauriFS = await import("../tauri_fs");
                await TauriFS.saveFile(g.file.path, g.content);
                console.log("Saved via Tauri:", g.file.path);
                // Optionally show a toast or status
             } catch (e) {
                 console.error("Tauri Save Error:", e);
                 alert("Failed to save file: " + e);
             }
        } else if (channel) {
            channel.push("editor:save", { path: g.file.path, content: g.content });
        }
    }

    toggleAutoSave() {
        this.autoSave = !this.autoSave;
    }
}

export const editor = new EditorState();
