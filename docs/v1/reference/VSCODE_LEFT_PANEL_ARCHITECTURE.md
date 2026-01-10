# VS Code Left Panel Architecture Study

## 🏗️ Structure Overview

The VS Code left panel consists of two main parts:

### 1. **ActivityBar** (`activitybarPart.ts`)
- Fixed width: **48px** 
- Vertical icon bar for view container switching
- Contains: File Explorer, Search, Git, Extensions icons
- Supports positions: LEFT (default), RIGHT, TOP, BOTTOM, HIDDEN

**Key Properties:**
```typescript
readonly minimumWidth: number = 48;
readonly maximumWidth: number = 48;
iconSize: 24,
compositeSize: 52,
ACTION_HEIGHT = 48
```

### 2. **Sidebar** (`sidebarPart.ts`)
- Resizable width: **170px min** to ∞
- Contains the actual view content (Explorer tree, Search panel, etc.)
- Has its own composite bar when activity bar is in TOP/BOTTOM position

**Key Properties:**
```typescript
readonly minimumWidth: number = 170;
readonly maximumWidth: number = Number.POSITIVE_INFINITY;
```

---

## 🎨 Theme Color Tokens (Left Panel)

| Token | Purpose |
|-------|---------|
| `ACTIVITY_BAR_BACKGROUND` | ActivityBar background |
| `ACTIVITY_BAR_FOREGROUND` | Active icon color |
| `ACTIVITY_BAR_INACTIVE_FOREGROUND` | Inactive icon color |
| `ACTIVITY_BAR_BORDER` | Right border of activity bar |
| `ACTIVITY_BAR_BADGE_BACKGROUND` | Badge (count) background |
| `ACTIVITY_BAR_BADGE_FOREGROUND` | Badge text color |
| `ACTIVITY_BAR_ACTIVE_BORDER` | Left border of active icon |
| `SIDE_BAR_BACKGROUND` | Sidebar background |
| `SIDE_BAR_FOREGROUND` | Sidebar text color |
| `SIDE_BAR_BORDER` | Right border of sidebar |
| `SIDE_BAR_TITLE_FOREGROUND` | Section title color |

---

## 🔧 Key Architectural Patterns

### Composite Bar System
Both parts use `PaneCompositeBar` for managing view containers:
- Pinned views storage key
- Drag & drop reordering
- Overflow handling
- Badge rendering

### Position Configuration
```typescript
enum ActivityBarPosition {
  DEFAULT = 'default',  // Left side
  TOP = 'top',          // In sidebar header
  BOTTOM = 'bottom',    // In sidebar footer
  HIDDEN = 'hidden'     // Invisible
}
```

### Layout Priority
```typescript
readonly priority: LayoutPriority = LayoutPriority.Low; // Sidebar shrinks first
```

---

## 📍 Mapping to Ether LiveView

| VS Code Part | Ether Equivalent |
|--------------|------------------|
| `activitybarPart.ts` | `workbench_live.html.heex` - ActivityBar div |
| `sidebarPart.ts` | `workbench_live.html.heex` - SideBar div |
| `PaneCompositeBar` | LiveView stream for view containers |
| Theme tokens | `vscode-tokens.css` + Tailwind classes |

---

## 📏 VS Code Reference Specs (Pixel-Perfect)

Derived from `vscode-main` source analysis (`activitybarpart.css`, `sidebarpart.css`):

### Activity Bar
- **Width**: `48px` fixed.
- **Layout**: Flexbox column, `justify-content: space-between` (Actions top, Settings/Account bottom).
- **Border**: `1px` solid, color inherited (dynamic based on theme).
- **Menu Bar Area**: `35px` height (if present).
- **Focus**: Custom focus indication (standard outline suppressed: `outline: 0`).

### Sidebar
- **Title Area**:
    - **Background**: `var(--vscode-sideBarTitle-background)`
    - **Text**: Uppercase (`text-transform: uppercase`).
    - **Actions**: `justify-content: flex-end`.
    - **Item Margin**: `4px` right.
- **Headers (Collapsible)**:
    - **Text**: Nowrap, ellipsis.
    - **Action Container**: `28px` width.
    - **Icons**: `16px` x `16px` centered.
- **Focus Ring**: `outline-offset: 2px`.

### 🧬 Nano-Spec: Dimensions & Constants

| Property | Value | Source |
|:---|:---|:---|
| **ActivityBar Width** | `48px` | `activitybarPart.ts` line 52 |
| **ActivityBar Action Height** | `48px` | `activitybarPart.ts` line 44 |
| **ActivityBar Icon Size** | `24px` | `activitybarPart.ts` line 80 |
| **ActivityBar Composite Size** | `52px` | `activitybarPart.ts` line 87 (includes margins) |
| **Sidebar Min Width** | `170px` | `sidebarPart.ts` line 42 |
| **Sidebar Header Icon Size** | `16px` | `sidebarPart.ts` line 192 (option `iconSize`) |
| **Sidebar Overflow Action** | `30px` | `sidebarPart.ts` line 193 |
| **Sidebar Snap** | `true` | `sidebarPart.ts` line 46 |

### ⚙️ Logic & Behaviors
- **Snapping**: Sidebar has `snap: true`, meaning it snaps to min-width or snaps shut.
- **Priority**: `LayoutPriority.Low` (Sidebar shrinks before Editor).
- **ActivityBar Position**: Supports `LEFT`, `RIGHT`, `TOP`, `BOTTOM`, `HIDDEN`.
- **Keybinding**: `Ctrl/Cmd + 0` triggers `workbench.action.focusSideBar`.

### 🎨 Exact Color Tokens
- `ACTIVITY_BAR_BACKGROUND` / `FOREGROUND`
- `ACTIVITY_BAR_ACTIVE_BORDER`
- `ACTIVITY_BAR_BADGE_BACKGROUND` / `FOREGROUND`
- `SIDE_BAR_BACKGROUND` / `FOREGROUND`
- `SIDE_BAR_BORDER`
- `SIDE_BAR_TITLE_FOREGROUND`

### 💅 CSS Nano-Details (activityaction.css)
- **Active Border**: `2px` width, `solid`, absolute positioning.
- **Badge Position**: `top: 24px`, `right: 8px`.
- **Badge Size**: `height: 16px`, `min-width: 8px`, `border-radius: 20px`.
- **Badge Font**: `9px`, `font-weight: 600`.
- **Icon Font**: `24px` (codicon), `15px` (text/label).
- **Icon Font**: `24px` (codicon), `15px` (text/label).
- **Hover Transition**: `100ms` delay on border appearance.

### 🧠 Deep Internal Architecture (The "Engine")
- **PaneCompositePart**: The generic container base class for Sidebar and Panel. It manages the lifecycle of "Composites" (Views).
    - *Responsibility*: Swapping active views, storing state (pinned/visible), and handling the "Empty State" message ("Drag a view here...").
- **CompositeBar**: The actual widget that renders the strip of icons (Activity Bar).
    - *Not just UI*: It's a localized MVC widget with its own model (`CompositeBarModel`) that tracks order, pinning, and visibility.
- **Lazy Instantiation**: Views (`PaneComposite`) are not created until opened.
- **Drag & Drop**: Uses `CompositeDragAndDrop` to allow reordering icons *between* the Activity Bar and Panel, or even moving views into new containers.

### 🗂️ The Internal "Split View" Engine (`ViewPaneContainer`)
Inside the Sidebar (e.g., Explorer), content is not static. It is a **Split View** of multiple collapsible sections:
- **`ViewPaneContainer`**: The manager for a specific sidebar view (like "Explorer"). It holds a list of `ViewPane`s.
- **`ViewPane`**: The base class for the collapsible headers (e.g., "Open Editors", "Timeline").
    - **Header Toolbar**: Each pane has its own `WorkbenchToolBar` in the header (e.g., "New File", "Refresh").
    - **Progress Bar**: Each pane has a `ProgressBar` (hidden by default) for async operations.
    - **Welcome Controller**: Handles the "Empty State" (e.g., "No Folder Opened") with actionable buttons.
- **`PaneView`**: The actual UI widget that renders the vertical list of collapsible panes, handling resizing sashes and animations.

### 🧩 Advanced Features
- **Filter Widget (`viewFilter.ts`)**: A standardized `HistoryInputBox` used for filtering lists (e.g., in the Problems panel or efficient tree search). It includes a "More Filters..." submenu.
- **View Actions (`viewMenuActions.ts`)**:
    - **`ViewContainerMenuActions`**: Scoped menu logic for the sidebar title "..." button.
    - **Context Awareness**: Menus are aware of their `viewContainerLocation` (Sidebar vs Panel).
- **Activity Bar Integration**: The Sidebar *can* host the Activity Bar (horizontal mode) if configured to `top` or `bottom` via `ActivityBarCompositeBar`.

### 🏭 Concrete Implementation (Explorer Case Study)
- **`ExplorerView` extends `ViewPane`**: The actual file explorer is a subclass of the generic pane.
- **`WorkbenchCompressibleAsyncDataTree`**: The engine powering the file tree. It handles:
    - **Compression**: Collapsing empty intermediate directories (e.g., `src/main/java`).
    - **Async Loading**: Fetching children only on expansion.
- **`SplitView` Dynamics**:
    - **Absolute Positioning**: `VerticalViewItem` sets `top` and `height` explicitly.
    - **Sash Mechanics**: Handles mouse events to resize panes, respecting `minimumSize` and `maximumSize` constraints.
- **Decorations**: `ExplorerDecorationsProvider` handles basic states (Symlinks, Errors, Excluded), while Git colors are injected via `IDecorationsService`.
