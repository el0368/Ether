# Tailwind CSS Roadmap

## 🎨 Core Strategy
- **Engine:** Tailwind v4 (Oxide) for instant compilation.
- **Design System:** VS Code Dark Theme mimicry.
- **No Component Libraries:** Removing DaisyUI to avoid "web-app look".

## ✅ Completed
- [x] **Setup:** Installed in `assets/` via Bun.
- [x] **Integration:** Working with Svelte 5.

## 🚧 In Progress (Theme Migration)
- [ ] **Step 1: Variables:** Define VS Code CSS variables in `app.css`.
  - `--vscode-editor-background`
  - `--vscode-sideBar-background`
  - `--vscode-list-activeSelectionBackground`
- [ ] **Step 2: Cleanup:** Remove `@plugin "daisyui"`.
- [ ] **Step 3: Component Update:** Refactor `SideBar.svelte` and `FileExplorer.svelte` to use new variables.

## 🔮 Future
- [ ] **Themes:** Allow user to swap CSS variable sets (e.g. GitHub Light).
- [ ] **Animations:** Hardware-accelerated transitions for UI panels.
