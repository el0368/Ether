# DaisyUI to VS Code Theme Migration Plan

**Date:** 2026-01-04  
**Status:** Planning (Not Yet Implemented)  
**Estimated Effort:** 1-2 hours

---

## Current State: DaisyUI Usage Analysis

### Files Using DaisyUI Classes (13 Svelte files total)

| File | DaisyUI Classes Used |
|------|---------------------|
| `SideBar.svelte` | `bg-base-300` |
| `FileExplorer.svelte` | `bg-base-300/50`, `text-primary` |
| `App.svelte` | `bg-base-*` colors |
| Other components | Similar color/utility classes |

### Main DaisyUI Features Being Used

1. **Color System** - `bg-base-100`, `bg-base-200`, `bg-base-300`, `text-primary`
2. **Opacity variants** - `bg-base-300/50`
3. **Theme Variables** - CSS variables for colors

### What's NOT Being Used (Good News!)

- ❌ No `btn`, `btn-primary` buttons
- ❌ No `modal`, `drawer` components
- ❌ No `badge`, `tooltip`, `kbd` classes
- ❌ No complex DaisyUI components

---

## Target State: VS Code Design System

### 1. Fonts

**UI Font (menus, sidebar, etc.):**
```css
font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, 
             "Helvetica Neue", Arial, sans-serif;
```

**Editor Font (code):**
```css
font-family: "Cascadia Code", "Fira Code", Consolas, "Courier New", monospace;
font-size: 14px;
line-height: 1.5;
```

### 2. Colors (Dark Default Theme)

```css
:root {
  /* Backgrounds */
  --vscode-editor-background: #1e1e1e;        /* Main editor */
  --vscode-sideBar-background: #252526;       /* Sidebar */
  --vscode-activityBar-background: #333333;   /* Left icon bar */
  --vscode-titleBar-background: #323233;      /* Title bar */
  --vscode-tab-activeBackground: #1e1e1e;     /* Active tab */
  --vscode-tab-inactiveBackground: #2d2d2d;   /* Inactive tabs */
  --vscode-statusBar-background: #007acc;     /* Status bar (blue) */
  
  /* Text */
  --vscode-foreground: #cccccc;               /* Normal text */
  --vscode-descriptionForeground: #858585;    /* Muted text */
  --vscode-sideBar-foreground: #cccccc;       /* Sidebar text */
  
  /* Accents */
  --vscode-focusBorder: #007acc;              /* Focus outline (blue) */
  --vscode-selection-background: #264f78;     /* Selected text */
  --vscode-list-activeSelectionBackground: #094771;  /* Selected item */
  --vscode-list-hoverBackground: #2a2d2e;     /* Hover state */
  
  /* Borders */
  --vscode-panel-border: #80808059;           /* Panel borders */
  --vscode-sideBar-border: #80808059;         /* Sidebar border */
}
```

### 3. File Icons

VS Code uses **Seti** (built-in) or **Material Icons** (extension).

| Extension | Icon Color |
|-----------|------------|
| `.js` | Yellow |
| `.ts` | Blue |
| `.json` | Yellow/Orange |
| `.md` | Blue |
| Folders | Brown/Orange |

**Icon Sources:**
- [vscode-icons](https://github.com/vscode-icons/vscode-icons)
- [Material Icons](https://github.com/PKief/vscode-material-icon-theme)
- Seti UI (Built into VS Code)

### 4. Layout Dimensions

```css
--activity-bar-width: 48px;
--sidebar-width: 240px;
--title-bar-height: 30px;
--status-bar-height: 22px;
--tab-height: 35px;
--list-row-height: 22px;
```

### 5. Typography Scale

| Element | Size | Weight |
|---------|------|--------|
| Title Bar | 13px | 400 |
| Sidebar Headers | 11px | 600 (uppercase) |
| File Names | 13px | 400 |
| Status Bar | 12px | 400 |
| Editor | 14px | 400 |

### 6. Key Visual Patterns

1. **Hover states**: Slightly lighter background (`#2a2d2e`)
2. **Selected states**: Blue-ish highlight (`#094771`)
3. **Focus states**: Blue border (`#007acc`)
4. **Inactive states**: Slightly dimmed colors
5. **Borders**: Very subtle, often transparent

---

## Migration Plan

### Step 1: Create VS Code Color Variables

Add to `assets/src/app.css`:
```css
@import "tailwindcss";

:root {
  /* VS Code Dark Theme */
  --vscode-editor-background: #1e1e1e;
  --vscode-sideBar-background: #252526;
  --vscode-activityBar-background: #333333;
  --vscode-titleBar-background: #323233;
  --vscode-statusBar-background: #007acc;
  --vscode-foreground: #cccccc;
  --vscode-focusBorder: #007acc;
  --vscode-list-hoverBackground: #2a2d2e;
  --vscode-list-activeSelectionBackground: #094771;
}
```

### Step 2: Class Replacement Map

| DaisyUI Class | Tailwind Replacement |
|---------------|---------------------|
| `bg-base-100` | `bg-[#1e1e1e]` or `bg-[var(--vscode-editor-background)]` |
| `bg-base-200` | `bg-[#252526]` or `bg-[var(--vscode-sideBar-background)]` |
| `bg-base-300` | `bg-[#333333]` or `bg-[var(--vscode-activityBar-background)]` |
| `text-primary` | `text-[#007acc]` or `text-[var(--vscode-focusBorder)]` |
| `bg-base-300/50` | `bg-[#33333380]` |

### Step 3: Files to Update

1. `App.svelte`
2. `SideBar.svelte`
3. `FileExplorer.svelte`
4. `ActivityBar.svelte`
5. `TitleBar.svelte`
6. `StatusBar.svelte`
7. `EditorLayout.svelte`
8. `Terminal.svelte`
9. `CommandPalette.svelte`
10. `GitPanel.svelte`
11. `SearchPanel.svelte`
12. `RefactorModal.svelte`
13. `MonacoEditor.svelte`

### Step 4: Remove DaisyUI

In `assets/src/app.css`, remove:
```css
@plugin "daisyui";  /* DELETE THIS LINE */
```

### Step 5: Test Each Component

Run through all UI components to verify styling is correct.

---

## Summary

| Aspect | Current (DaisyUI) | Target (VS Code) |
|--------|-------------------|------------------|
| UI Font | Default | System font stack |
| Code Font | Default | Cascadia Code |
| Icon Theme | None | Seti/Material Icons |
| Color Palette | DaisyUI base colors | VS Code grays + blue |
| Design System | DaisyUI plugin | Custom CSS variables |

---

## Decision

**Status:** Documented for future implementation.

This migration is **optional** and can be done when:
1. We have stable core functionality
2. We want to match VS Code's look exactly
3. We want to remove the DaisyUI dependency
