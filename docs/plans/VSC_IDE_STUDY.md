# Plan: vscode-main Deep Dive Study

This document outlines the systematic analysis of the `vscode-main` folder (Code - OSS fork) to support the future development of the Ether IDE.

## 📍 Phased Analysis Strategy

| Phase | Focus Area | Goal | Status |
| :--- | :--- | :--- | :--- |
| **Phase I** | **Structural Mapping** | Map the root layers (`base`, `platform`, `editor`, `workbench`) and confirm repository origin. | **COMPLETED** |
| **Phase II** | **The Intelligence Layer** | Deep analyze `src/vs/platform/mcp`. Understand how the Model Context Protocol is natively integrated for AI agents. | *In Queue* |
| **Phase III** | **Editor & Extension Bridge** | Study the Monaco core (`src/vs/editor`) and how the workbench interacts with the Svelte-based frontend via custom services or the Extension API. | *In Queue* |
| **Phase IV** | **Build & Bundling Internals** | Analyze `gulpfile.mjs`, `scripts/`, and the desktop entry points to understand how the code is optimized and delivered as a product. | *In Queue* |

---

## 🔍 Detailed Phase Descriptions

### Phase I: Structural Mapping (Completed)
- **Files Analyzed**: `README.md`, `package.json`, `src/vs/*`.
- **Outcome**: Confirmed complete Code - OSS fork. Identified the non-standard `mcp` platform layer.
- **Artifact**: [Study Report (Session 26)](file:///c:/GitHub/Ether/docs/logs/DEVLOG.md#session-26-vscode-main-architectual-study-2026-01-08)

### Phase II: The Intelligence Layer (MCP)
- **Objective**: Decipher the custom MCP implementation.
- **Key Files**: 
    - `src/vs/platform/mcp/common/mcpManagementService.ts`
    - `src/vs/platform/mcp/common/mcpGalleryService.ts`
- **Questions**:
    - How are TCP/Stdio transports handled?
    - How does the "Gallery" manifest sync with external servers?
    - How can we inject custom "Ether" tools into this layer?

### Phase III: Editor & Extension Bridge
- **Objective**: Understand the UI-to-Core communication.
- **Key Areas**: 
    - `src/vs/workbench` (UI Layout/Actions)
    - `src/vs/editor/browser` (Monaco rendering)
- **Integration Point**: How does the Svelte frontend in `assets/` eventually replace or embed this workbench?

### Phase IV: Build & Desktop Encapsulation
- **Objective**: Roadmap the path to a production binary.
- **Key Areas**:
    - Build system dependencies (`npm install` footprint).
    - Tauri vs. Electron overlap (are we using the standard VS Code desktop shell or a custom Tauri shell?).

---

## 📈 Integration with Roadmap 
This study is a prerequisite for **Milestone 2: "The Editor"** and **Milestone 3: "The Intelligence"** as defined in the [Master Roadmap](file:///c:/GitHub/Ether/docs/plans/ROADMAP.md).
