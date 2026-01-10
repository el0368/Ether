# Comparison Study: VS Code vs. Ether Sidebar Implementation

This document compares the architectural and functional implementation of the Activity Bar and Sidebar in VS Code (`vscode-main`) with the current state of the Ether project.

## 1. Click Behavior (Activity Bar Icons)

### VS Code
- **Left-Click (Smart Toggle):** 
  - If the sidebar is hidden: Opens sidebar with the clicked view.
  - If the sidebar is visible + clicked view is already active: Toggles (hides) the sidebar (configurable behavior).
  - If the sidebar is visible + different view active: Switches views within the sidebar.
- **Double-Click Protection:** Implements a `preventDoubleClickDelay` (300ms) to ignore accidental double-clicks.
- **Implementation:** `ViewContainerActivityAction.run` in [paneCompositeBar.ts](file:///c:/GitHub/Ether/vscode-main/vscode-main/src/vs/workbench/browser/parts/paneCompositeBar.ts).

### Ether
- **Left-Click (Basic Toggle):**
  - Implements basic toggle logic (if active + visible, hide; else show).
  - **Missing:** Double-click protection.
- **Implementation:** `SidebarControl` JS hook in [sidebar_control.js](file:///c:/GitHub/Ether/assets/js/hooks/sidebar_control.js).

---

## 2. Right-Click Behavior (Context Menus)

### VS Code
- **Functional Context Menu:** Right-clicking an icon opens a rich menu:
  - **Pin/Unpin:** Keeps or removes the icon from the bar.
  - **Hide/Show Badge:** Toggles notification count visibility.
  - **Move To:** Relocates the view container to another part (Panel, Secondary Side Bar).
  - **Reset Location:** Restores defaults.
- **Background Menu:** Right-clicking the empty area allows re-enabling hidden (unpinned) icons.
- **Implementation:** `CompositeActionViewItem.showContextMenu` in [compositeBarActions.ts](file:///c:/GitHub/Ether/vscode-main/vscode-main/src/vs/workbench/browser/parts/compositeBarActions.ts).

### Ether
- **None:** Currently, right-clicking activity bar icons has no effect (delegates to browser default or does nothing).
- **Hardcoded Icons:** Activity icons are hardcoded in [activity_bar.ex](file:///c:/GitHub/Ether/lib/ether_web/components/workbench/activity_bar.ex), making dynamic pinning/hiding impossible in the current UI architecture.

---

## 3. Open/Close (Visibility Management)

### VS Code
- **Layout Integration:** Uses a global `IWorkbenchLayoutService.setPartHidden` method.
- **Grid System:** Sidebar visibility is a fundamental state of the workbench grid. Hiding it triggers a recalculation of the editor area and other parts.
- **Implementation:** [Part.ts](file:///c:/GitHub/Ether/vscode-main/vscode-main/src/vs/workbench/browser/parts/compositePart.ts) and [layoutService.ts](file:///c:/GitHub/Ether/vscode-main/vscode-main/src/vs/workbench/services/layout/browser/layoutService.ts).

### Ether
- **Optimistic CSS:** Uses JS to immediately toggle CSS classes (`w-0`, `opacity-0`) for instant feedback.
- **Server Sync:** Pushes a `set_sidebar` event to update the server session state.
- **Transition:** Uses Tailwind transitions (`transition-all duration-150`).

---

## 4. Technical Architecture

### VS Code (Modular & Service-Based)
- **Part Base:** [SidebarPart](file:///c:/GitHub/Ether/vscode-main/vscode-main/src/vs/workbench/browser/parts/sidebar/sidebarPart.ts#36-300) and [ActivitybarPart](file:///c:/GitHub/Ether/vscode-main/vscode-main/src/vs/workbench/browser/parts/activitybar/activitybarPart.ts#42-192) inherit from common [Part](file:///c:/GitHub/Ether/vscode-main/vscode-main/src/vs/workbench/services/layout/browser/layoutService.ts#213-214) or [AbstractPaneCompositePart](file:///c:/GitHub/Ether/vscode-main/vscode-main/src/vs/workbench/browser/parts/paneCompositePart.ts#107-701) classes.
- **Composite Manager:** Uses [PaneCompositeBar](file:///c:/GitHub/Ether/vscode-main/vscode-main/src/vs/workbench/browser/parts/paneCompositeBar.ts#88-769) and [CompositeBar](file:///c:/GitHub/Ether/vscode-main/vscode-main/src/vs/workbench/browser/parts/compositeBarActions.ts#34-73) to manage a dynamic list of view containers.
- **Registry System:** Views are registered via a global registry (`Extensions.Viewlets`), allowing extensions to contribute new icons.
- **State Persistence:** Heavily uses `IStorageService` to remember pinned/unpinned states across sessions.

### Ether (Component & Hook Based)
- **Static Components:** Sidebar and Activity Bar are Phoenix LiveView components with pre-defined panels.
- **JS Hook Orchestration:** Most of the "VS Code feel" (smooth transitions, quick switching) is handled in a single JS hook.
- **Stateless UI:** Currently relies on server-side state (`active_sidebar`, `sidebar_visible`) passed as attributes.

---

## Summary Findings

| Feature | VS Code | Ether |
| :--- | :--- | :--- |
| **View Switching** | Service-driven, supports background loading | Instant panel swap via CSS/Visibility |
| **Toggle Logic** | Configurable (Focus vs Toggle) | Hardcoded Toggle |
| **Right-Click** | Rich management (Pin/Unpin/Move) | Not implemented |
| **Customization** | Dynamic, extension-friendly | Static, template-based |
| **Persistence** | Multi-level storage (Workspace/User) | Basic session state |
