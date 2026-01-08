# Nano-Plan: Phase I (Visual Identity)

This document provides surgical, step-by-step instructions for extracting the "Skin" of VS Code.

## 📍 Step 1.1: Color Registry Extraction (The Semantic Map)
- [ ] **1.1.1: Directory Audit**
    - List all files in `src/vs/platform/theme/common/colors/`.
- [ ] **1.1.2: Pattern Matching**
    - Scan `baseColors.ts` and `editorColors.ts` for the pattern `registerColor('key', { dark: ..., light: ... }, 'description')`.
- [ ] **1.1.3: Master Key List**
    - Create a JSON object where keys are the VS Code semantic IDs (e.g., `editor.background`) and values are the default logic references.

## 📍 Step 1.2: Theme Payload Extraction (The Hex Values)
- [ ] **1.2.1: JSON Hierarchy Flattening**
    - Read `extensions/theme-defaults/themes/dark_vs.json`.
    - Deep-merge it with `dark_plus.json`.
- [ ] **1.2.2: Semantic-to-Hex Mapping**
    - Cross-reference the "colors" block from the JSON with our Master Key List (1.1.3).
- [ ] **1.2.3: Syntax Token Extraction**
    - Extract the `tokenColors` array for language-specific highlighting variables.

## 📍 Step 1.3: CSS Variable Generation (The Injection)
- [ ] **1.3.1: Naming Convention Script**
    - Convert `dot.notated.keys` to `--vscode-dot-notated-keys`.
- [ ] **1.3.2: Static Variable Block**
    - Generate `:root { ... }` block in `assets/src/lib/styles/vscode-tokens.css`.

## 📍 Step 1.4: Iconography & Font Assets
- [ ] **1.4.1: Find Font Source**
    - Locate `codicon.ttf` and `codicon.css` in `src/vs/base/browser/ui/codicons/`.
- [ ] **1.4.2: Asset Relocation**
    - Copy font files to `assets/static/fonts/`.
- [ ] **1.4.3: Svelte Wrapper**
    - Implement `VscodeIcon.svelte` using CSS mask or font-family mapping.

## 📍 Step 1.5: Typography Alignment
- [ ] **1.5.1: Font Stack definition**
    - Hardcode `--vscode-font-family: 'Inter', system-ui, sans-serif;`.
    - Hardcode `--vscode-editor-font-family: 'Monaco', 'Courier New', monospace;`.

## 📍 Step 1.6: Reactive Store Integration
- [ ] **1.6.1: Store Definition**
    - Create `assets/src/lib/state/theme.svelte.js` exporting `const currentTheme = $state('dark-plus');`.
- [ ] **1.6.2: Dynamic Injection**
    - Create a function `updateThemeVars(themeName)` that fetches JSON from `assets/static/themes/` and updates the CSS variable block on the `<body>` element.
