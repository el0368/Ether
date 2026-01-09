# Plan: UI/UX Extraction from vscode-main

A focused strategy to extract the Visual Studio Code user experience and interface elements for integration into the Ether **Phoenix LiveView** frontend.

## 📍 Phased Extraction Strategy

| Phase | Focus Area | Goal | Status |
| :--- | :--- | :--- | :--- |
| **Phase I** | **Visual Identity (Tokens)** | Extract the CSS variables, color themes, typography, and iconography. | **[x]** |
| **Phase II** | **Workbench LiveView Shell** | Map and replicate the Workbench shell parts in HEEx. | **[x]** |
| **Phase III** | **JS Hook Consolidation** | Implement high-performance JS Hooks for Monaco and Xterm.js. | **[x]** |
| **Phase IV** | **Unified Testing & LSP** | Implement LiveView tests (ExUnit) and integrated LSP feedback. | [/] |

---

## 🔍 Detailed Phase Descriptions

### Phase I: Visual Identity & Design Tokens [x]
- [x] **Step 1.1: Color Registry Extraction**
- [x] **Step 1.2: Default Theme Parsing**
- [x] **Step 1.3: Token Generation**
- [x] **Step 1.4: Iconography Setup**
- [x] **Step 1.5: Typography Alignment**
- [x] **Step 1.6: Reactive UI State**

### Phase II: Structural Shell & Layout [x]
- [x] **Step 2.1: Semantic Layout Variables**
- [x] **Step 2.2: The Grid Engine**
- [x] **Step 2.3: Atomic Shell Parts**
- [x] **Step 2.4: The Resizable SplitView**
- [x] **Step 2.5: SideBar & Panel Orchestration**
- [x] **Step 2.6: Layout Persistence**

### Phase III: Interactive Component Logic [x]
- [x] **Step 3.1: The QuickPicker UI**
- [x] **Step 3.2: Command Palette Logic**
- [x] **Step 3.3: Unified Tree/List Component**
- [x] **Step 3.4: Context Menu System**
- [x] **Step 3.5: Keyboard & Focus Management**
- [ ] **Step 3.6: Drag & Drop Logic**

### Phase IV: Unified Testing & Quality [/]
- [x] **Step 4.1: LiveView Tests**: ExUnit scripts for structural integrity.
- [x] **Step 4.2: Micro-Benchmarks**: Benchee for scanner performance.
- [ ] **Step 4.3: LSP Diagnostics**: Real-time error reporting in UI.
- [x] **Step 4.4: Telemetry**: Real-time monitoring via Phoenix Dashboard.

---

## 🛣️ Impact on Master Roadmap
This focused plan accelerates **Milestone 2: "The Editor"** by decoupling the UI design from the heavy backend service implementation.

---
*Last Updated: 2026-01-09*
