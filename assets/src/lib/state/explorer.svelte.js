import { applyDelta as applyDeltaLogic } from "../delta_handler";

export class ExplorerState {
    fileTree = $state.raw([]);
    pendingFiles = [];
    expandedPaths = $state(new Set());
    rootPath = $state("");

    addChunk(files) {
        this.pendingFiles.push(...files);
    }

    flushBatch() {
        if (this.pendingFiles.length > 0) {
            try {
                if (this.pendingFiles.length > 5000) {
                    this.fileTree = [...this.fileTree, ...this.pendingFiles];
                } else {
                    this.fileTree.push(...this.pendingFiles);
                }
            } catch (e) {
                console.error("Batch Flush Error:", e);
                for (const f of this.pendingFiles) {
                    this.fileTree.push(f);
                }
            }
            this.pendingFiles = [];
        }
    }

    applyDelta(payload) {
        let type = payload.type;
        if (type === "created") type = "add";
        if (type === "deleted") type = "remove";
        if (type === "modified") type = "modify";
        this.fileTree = applyDeltaLogic(this.fileTree, { path: payload.path, type: type });
    }

    // Persistence
    saveState() {
        if (typeof localStorage !== 'undefined') {
            localStorage.setItem("ether_root_path", this.rootPath);
        }
    }

    loadState() {
        if (typeof localStorage !== 'undefined') {
            return localStorage.getItem("ether_root_path");
        }
        return null;
    }

    clear() {
        this.fileTree = [];
        this.pendingFiles = [];
    }

    sort() {
        this.fileTree.sort((a, b) => a.path.localeCompare(b.path));
    }

    // Tauri Native: Orchestration
    async openFolder(channel) {
        const isTauri = typeof window !== 'undefined' && '__TAURI__' in window;
        
        if (isTauri) {
            try {
                const TauriFS = await import("../tauri_fs");
                const path = await TauriFS.pickFolder();
                if (path) {
                    await this.loadFolder(path);
                }
            } catch (e) {
                console.error("Native Open Folder Error:", e);
            }
        } else if (channel) {
            channel.push("filetree:list_raw", { path: "." });
        }
    }

    async loadFolder(path) {
        try {
            const uiModule = await import("./ui.svelte");
            uiModule.ui.isLoading = true;
            this.clear();
            
            const TauriFS = await import("../tauri_fs");
            const files = await TauriFS.listDirectory(path);
            
            this.fileTree = files.map(f => ({
                name: f.name,
                path: f.path,
                type: f.type,
                is_dir: f.type === 'directory',
                size: f.size
            }));
            
            this.setRootPath(path);
            uiModule.ui.isLoading = false;
        } catch (e) {
            console.error("Load Folder Error:", e);
            const uiModule = await import("./ui.svelte");
            uiModule.ui.isLoading = false;
        }
    }

    closeFolder() {
        this.clear();
        this.rootPath = "";
        this.saveState();
    }

    // Tauri Native: Set files directly from Rust
    setFiles(files) {
        this.fileTree = files;
    }

    // Set the root folder path (for display purposes)
    setRootPath(path) {
        this.rootPath = path;
        this.saveState();
    }
}

export const explorer = new ExplorerState();
