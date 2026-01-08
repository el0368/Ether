import { ui } from "./ui.svelte";
import { editor } from "./editor.svelte";
import { comms } from "./comms.svelte";
import { explorer } from "./explorer.svelte";

export const menuState = {
    get fileMenuItems() {
        return [
            { label: "New Text File", shortcut: "Ctrl+N", action: () => editor.newUntitled() },
            { label: "New File...", shortcut: "Ctrl+Alt+Windows+N", action: () => {} },
            { label: "New Window", shortcut: "Ctrl+Shift+N", action: () => {} },
            { 
                label: "New Window with Profile", 
                submenu: true, 
                items: [
                    { label: "Default" },
                    { label: "Mathematics" },
                    { label: "Agent Dev" }
                ]
            },
            { separator: true },
            { label: "Open File...", shortcut: "Ctrl+O", action: () => ui.openPalette("files") },
            { label: "Open Folder...", shortcut: "Ctrl+K Ctrl+O", action: () => explorer.openFolder(comms.channel) },
            { label: "Open Workspace from File...", action: () => {} },
            { 
                label: "Open Recent", 
                submenu: true, 
                items: [
                    { label: "Ether" },
                    { label: "Academy" },
                    { separator: true },
                    { label: "More..." }
                ]
            },
            { separator: true },
            { label: "Add Folder to Workspace...", action: () => {} },
            { label: "Save Workspace As...", action: () => {} },
            { label: "Duplicate Workspace", action: () => {} },
            { separator: true },
            { label: "Save", shortcut: "Ctrl+S", action: () => {
                editor.save(comms.channel);
            }},
            { label: "Save As...", shortcut: "Ctrl+Shift+S", action: () => {} },
            { label: "Save All", shortcut: "Ctrl+K S", action: () => {} },
            { separator: true },
            { 
                label: "Share", 
                submenu: true, 
                items: [
                    { label: "Export as PDF" },
                    { label: "Publish to GitHub" }
                ]
            },
            { separator: true },
            { label: "Auto Save", checked: editor.autoSave, action: () => editor.toggleAutoSave() },
            { 
                label: "Preferences", 
                submenu: true, 
                items: [
                    { label: "Settings", shortcut: "Ctrl+," },
                    { label: "Keyboard Shortcuts", shortcut: "Ctrl+K Ctrl+S" },
                    { label: "Color Theme" }
                ]
            },
            { separator: true },
            { label: "Revert File", action: () => {} },
            { label: "Close Editor", shortcut: "Ctrl+F4", action: () => editor.closeEditor(editor.activeIndex) },
            { label: "Close Folder", shortcut: "Ctrl+K F", action: () => {
                explorer.closeFolder();
                editor.closeAll();
            }},
            { label: "Close Window", shortcut: "Alt+F4", action: () => {} },
            { separator: true },
            { label: "Exit", action: () => {} },
        ];
    },

    get editMenuItems() {
        return [
            { label: "Undo", shortcut: "Ctrl+Z", action: () => {} },
            { label: "Redo", shortcut: "Ctrl+Y", action: () => {} },
            { separator: true },
            { label: "Cut", shortcut: "Ctrl+X", action: () => {} },
            { label: "Copy", shortcut: "Ctrl+C", action: () => {} },
            { label: "Paste", shortcut: "Ctrl+V", action: () => {} },
            { separator: true },
            { label: "Find", shortcut: "Ctrl+F", action: () => {} },
            { label: "Replace", shortcut: "Ctrl+H", action: () => {} },
            { separator: true },
            { label: "Find in Files", shortcut: "Ctrl+Shift+F", action: () => ui.toggleSidebar("search") },
            { label: "Replace in Files", shortcut: "Ctrl+Shift+H", action: () => {} },
            { separator: true },
            { label: "Toggle Line Comment", shortcut: "Ctrl+/", action: () => {} },
            { label: "Toggle Block Comment", shortcut: "Shift+Alt+A", action: () => {} },
        ];
    },

    get viewMenuItems() {
        return [
            { label: "Command Palette...", shortcut: "Ctrl+Shift+P", action: () => ui.openPalette("files") },
            { label: "Open View...", action: () => {} },
            { separator: true },
            { label: "Appearance", submenu: true, action: () => {} },
            { label: "Editor Layout", submenu: true, action: () => {} },
            { separator: true },
            { label: "Explorer", shortcut: "Ctrl+Shift+E", action: () => ui.toggleSidebar("files") },
            { label: "Search", shortcut: "Ctrl+Shift+F", action: () => ui.toggleSidebar("search") },
            { label: "Source Control", shortcut: "Ctrl+Shift+G", action: () => ui.toggleSidebar("git") },
            { label: "Run and Debug", shortcut: "Ctrl+Shift+D", action: () => ui.toggleSidebar("debug") },
            { label: "Extensions", shortcut: "Ctrl+Shift+X", action: () => {} },
            { separator: true },
            { label: "Output", action: () => {} },
            { label: "Terminal", shortcut: "Ctrl+`", action: () => ui.toggleTerminal() },
            { label: "Problems", shortcut: "Ctrl+Shift+M", action: () => {} },
        ];
    },

    get selectionMenuItems() {
        return [
            { label: "Select All", shortcut: "Ctrl+A", action: () => {} },
            { label: "Expand Selection", shortcut: "Shift+Alt+Right", action: () => {} },
            { label: "Shrink Selection", shortcut: "Shift+Alt+Left", action: () => {} },
            { separator: true },
            { label: "Copy Line Up", shortcut: "Shift+Alt+Up", action: () => {} },
            { label: "Copy Line Down", shortcut: "Shift+Alt+Down", action: () => {} },
            { label: "Move Line Up", shortcut: "Alt+Up", action: () => {} },
            { label: "Move Line Down", shortcut: "Alt+Down", action: () => {} },
            { separator: true },
            { label: "Add Cursor Above", shortcut: "Ctrl+Alt+Up", action: () => {} },
            { label: "Add Cursor Below", shortcut: "Ctrl+Alt+Down", action: () => {} },
        ];
    },

    get helpMenuItems() {
        return [
            { label: "Welcome", action: () => { editor.activeGroup.file = null; } },
            { label: "Documentation", action: () => {} },
            { label: "Show All Commands", shortcut: "Ctrl+Shift+P", action: () => ui.openPalette("files") },
            { separator: true },
            { label: "About Ether", action: () => {} },
        ];
    }
};
