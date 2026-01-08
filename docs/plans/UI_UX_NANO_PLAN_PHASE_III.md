# Nano-Plan: Phase III (Interactive Component Logic)

This document provides surgical, step-by-step instructions for implementing the "Muscle" (Interaction Logic) of the Ether IDE.

## 📍 Step 3.1: The QuickPicker (Palette) UI
- [ ] **3.1.1: Overlay Primitive**
    - Create `assets/src/lib/components/ui/Overlay.svelte` for centered, floating modals.
- [ ] **3.1.2: QuickInput Container**
    - Build the container with an input field and a results list, modeled after `src/vs/platform/quickinput/browser/quickInput.ts`.

## 📍 Step 3.2: Fuzzy-Search Logic
- [ ] **3.2.1: Matcher Integration**
    - Port the fuzzy matching algorithm from `src/vs/base/common/filters.ts` (or use an optimized library like `fuzzysort`).
- [ ] **3.2.2: Dynamic Scoring**
    - Implement real-time scoring and highlight rendering for matching characters in the result list.

## 📍 Step 3.3: High-Performance Tree View
- [ ] **3.3.1: Tree Data Interface**
    - Define a generic `TreeNode` interface in Svelte modeled after `IObjectTreeElement<T>` from `src/vs/base/browser/ui/tree/tree.ts`.
- [ ] **3.3.2: Recursive Renderer**
    - Create `assets/src/lib/components/ui/Tree.svelte` and `TreeItem.svelte`.
    - Implement virtualization (if possible) or optimized lazy-unfolding for large project trees.

## 📍 Step 3.4: Context Menu Orchestration
- [ ] **3.4.1: Menu Registry**
    - Create `assets/src/lib/state/menu.svelte.js` to manage active context menu state and global "click-away" listeners.
- [ ] **3.4.2: Position Logic**
    - Implement smart positioning (e.g., flipping menu upward if near the bottom edge).

## 📍 Step 3.5: Keyboard & Focus Management
- [ ] **3.5.1: Global Key Listener**
    - Implement a central keyboard coordinator in `App.svelte` to handle `Ctrl+Shift+P`, `Esc`, and arrow-key navigation.
- [ ] **3.5.2: Focus Tunnels**
    - Ensure focus is trapped within the QuickPicker or active Modal while open.

## 📍 Step 3.6: Drag & Drop Feedback
- [ ] **3.6.1: DND Primitives**
    - Create `dragstart` and `dragover` handlers that inject VS Code style "ghost" previews of the being-dragged item.
- [ ] **3.6.2: Drop Target Indicators**
    - Implement the blue "insertion line" or "box highlight" for drop targets in the Tree and Editor area.
