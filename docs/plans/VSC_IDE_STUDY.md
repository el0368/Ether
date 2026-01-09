# Plan: vscode-main Deep Dive Study

This document outlines the systematic analysis of the `vscode-main` folder (Code - OSS fork).

## 📍 Phased Analysis Strategy

| Phase | Focus Area | Status |
| :--- | :--- | :--- |
| **Phase I** | **Structural Mapping** | [x] |
| **Phase II** | **The Intelligence Layer (MCP)** | [x] |
| **Phase III** | **Editor & Extension Bridge** | [/] |
| **Phase IV** | **Build & Bundling Internals** | [ ] |

---

## 🔍 Detailed Phase Descriptions

### Phase I: Structural Mapping [x]
- [x] Analyze root layers (`base`, `platform`, `editor`, `workbench`).
- [x] Identify non-standard `mcp` platform layer.
- [x] Document repository origin.

### Phase II: The Intelligence Layer (MCP) [x]
- [x] Decipher `McpManagementService` and `McpGalleryService`.
- [x] Trace `uvx`/Python dispatch logic.
- [x] Confirm native support for MCP transports.

### Phase III: Editor & Extension Bridge [/]
- [ ] **Workbench Actions**: Study how UI commands map to core services.
- [ ] **Monaco Browser**: Deep dive into `src/vs/editor/browser`.
- [ ] **Theme Registry**: Map the dynamic theme provider logic.

### Phase IV: Build & Desktop Encapsulation [ ]
- [ ] **Build Pipeline**: Analyze `gulpfile.mjs` and native module bundling.
- [ ] **Tauri Bridge**: Roadmap the transition from Electron abstractions to Tauri.

---
*Last Updated: 2026-01-09*
