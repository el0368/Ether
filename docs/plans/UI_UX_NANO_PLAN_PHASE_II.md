# Nano-Plan: Phase II (Structural Shell & Layout)

This document provides surgical, step-by-step instructions for implementing the "Skeleton" of the Ether IDE using VS Code primitives.

## 📍 Step 2.1: Semantic Layout Constants
- [ ] **2.1.1: Constant Extraction**
    - Target: `src/vs/workbench/browser/layout.ts`.
    - Extract: `MIN_SIDEBAR_WIDTH`, `MIN_PANEL_HEIGHT`, `ACTIVITY_BAR_WIDTH`.
- [ ] **2.1.2: CSS Variable Sync**
    - Define these in `assets/src/lib/styles/layout-constants.css` (e.g., `--ide-sidebar-min-width`).

## 📍 Step 2.2: The Grid Engine (Svelte Port)
- [ ] **2.2.1: Grid Primitive**
    - Create `assets/src/lib/components/ui/GridView.svelte`.
    - Logic: Partition a container into `views` based on weight/flex percentage, modeled after `src/vs/base/browser/ui/grid/gridview.ts`.
- [ ] **2.2.2: Directional Locking**
    - Implement `horizontal` and `vertical` modes for the GridView component.

## 📍 Step 2.3: Atomic Shell Implementation
- [ ] **2.3.1: Top/Bottom Parts**
    - Port `TitleBar.svelte` and `StatusBar.svelte` with fixed heights.
    - Path: `src/vs/workbench/browser/parts/titlebar/` and `statusbar/`.
- [ ] **2.3.2: Slot Orchestration**
    - Update `App.svelte` to use a root-level vertical GridView for (TitleBar -> MainArea -> StatusBar).

## 📍 Step 2.4: The Resizable Sash (Interaction)
- [ ] **2.4.1: Sash Component**
    - Create `assets/src/lib/components/ui/Sash.svelte`.
    - Logic: Capture `mousedown`, `mousemove`, and `mouseup` events to update the sibling's width/height percentage, modeled after `src/vs/base/browser/ui/sash/sash.ts`.
- [ ] **2.4.2: Feedback Cursors**
    - Map `sash-hover` states to `col-resize` and `row-resize` cursors.

## 📍 Step 2.5: SideBar & Panel Toggles
- [ ] **2.5.1: Global Layout State**
    - Enhance `assets/src/lib/state/ui.svelte.js` with:
        ```javascript
        export const layout = $state({
            sideBarVisible: true,
            panelVisible: false,
            sideBarWidth: 260,
            panelHeight: 300
        });
        ```
- [ ] **2.5.2: Conditional Rendering**
    - Update the MainArea GridView to reactively hide/show the SideBar and Panel based on the state above.

## 📍 Step 2.6: Persistence & Edge Cases
- [ ] **2.6.1: LocalStorage Sync**
    - Wrap the `layout` state in a `$effect` to persist changes to `localStorage` on every resize or toggle.
- [ ] **2.6.2: Constraint Enforcement**
    - Implement "Snapping" (e.g., if SideBar < 50px, toggle visibility to off).
