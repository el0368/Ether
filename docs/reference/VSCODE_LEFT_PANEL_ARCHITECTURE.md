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
