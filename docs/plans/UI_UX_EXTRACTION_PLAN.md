# Plan: UI/UX Extraction from vscode-main

A focused strategy to extract the Visual Studio Code user experience and interface elements for integration into the Ether **Phoenix LiveView** frontend.

## 📍 Phased Extraction Strategy

| Phase | Focus Area | Goal | Status |
| :--- | :--- | :--- | :--- |
| **Phase I** | **Visual Identity (Tokens)** | Extract the CSS variables, color themes, typography, and iconography (Seti/Codicons). | **[Completed]** |
| **Phase II** | **Workbench LiveView Shell** | Map and replicate the Workbench shell parts: TitleBar, ActivityBar, SideBar, and Panel grid in HEEx. | **[Completed]** |
| **Phase III** | **JS Hook Consolidation** | Implement high-performance JS Hooks for Monaco Editor and Xterm.js. | **[Completed]** |
| **Phase IV** | **Unified Testing & LSP** | Implement LiveView tests (ExUnit) and integrated LSP feedback. | *In Queue* |

---

## 🔍 Detailed Phase Descriptions

### Phase I: Visual Identity & Design Tokens (The Skin)
- **Objective**: Source and implement the complete VS Code design language (tokens).
- **Micro-Plan**:
    - [x] **Step 1.1: Color Registry Extraction**
        - Analyze `src/vs/platform/theme/common/colorRegistry.ts` to map semantic keys (e.g., `--vscode-editor-background`).
    - [x] **Step 1.2: Default Theme Parsing**
        - Extract hex values from `extensions/theme-defaults/themes/dark_plus.json`.
    - [x] **Step 1.3: Token Generation**
        - Create `assets/css/vscode-tokens.css` in Ether.
    - [x] **Step 1.4: Iconography Setup**
        - Identify the Codicon font path in `src/vs/base/browser/ui/codicons`.
        - Import font and integrate with Phoenix `Heroicons`.
    - [x] **Step 1.5: Typography Alignment**
        - Standardize font stacks: `Inter` for UI, `Monaco` for Editor.
    - [x] **Step 1.6: Reactive UI State**
        - Implement `WorkbenchLive` assigns for real-time state management.

### Phase II: Structural Shell & Layout (The Skeleton)
- **Objective**: Define and implement the responsive, resizable IDE layout.
- **Micro-Plan**:
- [x] **Step 2.1: Semantic Layout Variables**
- [x] **Step 2.2: The Grid Engine**
- [x] **Step 2.3: Atomic Shell Parts**
- [x] **Step 2.4: The Resizable SplitView**
- [x] **Step 2.5: SideBar & Panel Orchestration**
- [x] **Step 2.6: Layout Persistence**

### Phase III: Interactive Component Logic (The Muscle)
- **Objective**: Capture and implement the high-fidelity behaviors and interactive components of VS Code.
- **Micro-Plan**:
- [x] **Step 3.1: The QuickPicker UI**
- [x] **Step 3.2: Command Palette Logic**
- [x] **Step 3.3: Unified Tree/List Component**
- [x] **Step 3.4: Context Menu System**
- [x] **Step 3.5: Keyboard & Focus Management**
- [x] **Step 3.6: Drag & Drop Logic**

---

### Phase IV: Unified Testing & Quality (The Senses)
- **Objective**: Ensure long-term stability and high-fidelity performance.
- **Key Deliverables**:
    - **LiveView Tests**: ExUnit scripts for structural integrity.
    - **Micro-Benchmarks**: Benchee for scanner and rendering performance.
    - **Telemetry**: Real-time monitoring via Phoenix Dashboard.

---

## 🛣️ Impact on Master Roadmap
This focused plan accelerates **Milestone 2: "The Editor"** by decoupling the UI design from the heavy backend service implementation.
