# Plan: UI/UX Extraction from vscode-main

A focused strategy to extract the Visual Studio Code user experience and interface elements for integration into the Ether Svelte frontend.

## 📍 Phased Extraction Strategy

| Phase | Focus Area | Goal | Status |
| :--- | :--- | :--- | :--- |
| **Phase I** | **Visual Identity (Tokens)** | Extract the CSS variables, color themes, typography, and iconography (Seti/Codicons). | *In Queue* |
| **Phase II** | **Structural Shell (Layout)** | Map and replicate the Workbench shell parts: TitleBar, ActivityBar, SideBar, and Panel grid. | *In Queue* |
| **Phase III** | **Interactive Components** | Replicate high-frequency UI behaviors: Command Palette (QuickPick), Menus, and the Tree/List interaction model. | *In Queue* |

---

## 🔍 Detailed Phase Descriptions

### Phase I: Visual Identity & Design Tokens
- **Objective**: Sourcing the "Skin" of VS Code.
- **Key Resources**:
    - `src/vs/platform/theme`
    - `src/vs/base/browser/ui` (Basic UI styles)
- **Outcome**: A comprehensive CSS variable set that allows Ether to adopt any VS Code theme natively.

### Phase II: Structural Shell & Layout
- **Objective**: Defining the "Skeleton".
- **Key Areas**: 
    - `src/vs/workbench/browser/parts`
    - CSS Flex/Grid definitions for the workbench layout.
- **Outcome**: A responsive Svelte-based replica of the VS Code workbench container.

### Phase III: Interactive Component Logic
- **Objective**: Capturing the "Feel".
- **Key Components**:
    - **Command Palette**: The logic for filtering and selecting commands.
    - **Context Menus**: Standardizing the look and feel of right-click actions.
    - **Custom Views**: The protocol for injecting Svelte components into the VS Code SideBar containers.

---

## 🛣️ Impact on Master Roadmap
This focused plan accelerates **Milestone 2: "The Editor"** by decoupling the UI design from the heavy backend service implementation.
