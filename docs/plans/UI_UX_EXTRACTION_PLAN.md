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

### Phase I: Visual Identity & Design Tokens (The Skin)
- **Objective**: Source and implement the complete VS Code design language (tokens).
- **Micro-Plan**:
    - [ ] **Step 1.1: Color Registry Extraction**
        - Analyze `src/vs/platform/theme/common/colorRegistry.ts` to map semantic keys (e.g., `--vscode-editor-background`).
    - [ ] **Step 1.2: Default Theme Parsing**
        - Extract hex values from `extensions/theme-defaults/themes/dark_plus.json`.
    - [ ] **Step 1.3: Token Generation**
        - Create `assets/src/lib/styles/vscode-tokens.css` in Ether.
    - [ ] **Step 1.4: Iconography Setup**
        - Identify the Codicon font path in `src/vs/base/browser/ui/codicons`.
        - Import font and create a Svelte icon component.
    - [ ] **Step 1.5: Typography Alignment**
        - Standardize font stacks: `Inter` for UI, `Monaco` for Editor.
    - [ ] **Step 1.6: Reactive Theme Store**
        - Implement `assets/src/lib/state/theme.svelte.js` for real-time variable injection.

### Phase II: Structural Shell & Layout (The Skeleton)
- **Objective**: Define and implement the responsive, resizable IDE layout.
- **Micro-Plan**:
    - [ ] **Step 2.1: Semantic Layout Variables**
        - Analyze `src/vs/workbench/browser/layout.ts` to extract standard dimensions (e.g., `ACTIVITY_BAR_WIDTH: 48px`).
    - [ ] **Step 2.2: The Grid Engine**
        - Implement the base Svelte Grid container modeled after `src/vs/base/browser/ui/grid`.
    - [ ] **Step 2.3: Atomic Shell Parts**
        - Build the fixed-height static parts: `TitleBar` (top) and `StatusBar` (bottom).
    - [ ] **Step 2.4: The Resizable SplitView**
        - Port the "Sash" logic from `src/vs/base/browser/ui/sash` to Svelte for resizable boundaries.
    - [ ] **Step 2.5: SideBar & Panel Orchestration**
        - Implement the visibility toggle and positioning logic for the primary SideBar and the bottom Panel.
    - [ ] **Step 2.6: Layout Persistence**
        - Integrate `localStorage` tracking for panel widths and visibility states to ensure session continuity.

### Phase III: Interactive Component Logic
- **Objective**: Capturing the "Feel".
- **Key Components**:
    - **Command Palette**: The logic for filtering and selecting commands.
    - **Context Menus**: Standardizing the look and feel of right-click actions.
    - **Custom Views**: The protocol for injecting Svelte components into the VS Code SideBar containers.

---

## 🛣️ Impact on Master Roadmap
This focused plan accelerates **Milestone 2: "The Editor"** by decoupling the UI design from the heavy backend service implementation.
