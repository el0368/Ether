# Refactor Roadmap

## ✂️ Core Strategy
- **Role:** The "Surgeon" of the IDE.
- **Responsibility:** Safe, automated code transformations.
- **Philosophy:** Refactoring should be "Unduable" and "Safe" (AST-based, not regex-based).

## 🛠️ Tools
- **Elixir:** `Sourceror` for manipulating Abstract Syntax Trees (AST) while preserving comments and formatting.
- **JavaScript/TypeScript:** `jscodeshift` or `TS-Morph` for frontend transformations.
- **Agent:** `RefactorAgent` (GenServer) to orchestrate changes across multiple files.

## ✅ Completed
- [x] **RefactorAgent:** Basic GenServer structure exists in `lib/aether/agents/`.

## 🚧 Roadmap

### Phase 1: Logic Consolidation
- [ ] **Project Cleanup:** Identify and merge duplicate utility modules.
- [ ] **Pattern Harmonization:** Ensure all Agents follow the exact same GenServer + Channel patterns.
- [ ] **SPEL-AI Compliance:** Audit codebase for strict adherence to the SPEL-AI rules (Rune usage in Svelte, no `@apply` in CSS).

### Phase 2: Automated Actions (Elixir)
- [ ] **Rename Module:** Automatic update of all file references and file path relocation.
- [ ] **Extract Function:** Highlight code and move it to a private/public function.
- [ ] **Smart Imports:** Auto-add/remove `alias` and `import` based on usage.

### Phase 3: Frontend Refactoring
- [ ] **Svelte 4 to 5 Migration:** (If any legacy remains) Auto-convert properties to runes.
- [ ] **Tailwind Cleanup:** Identify unused classes or redundant style definitions.

## 🔮 Future
- [ ] **Refactor History:** Specialized "Refactor Log" in the DB to allow bulk-undo of complex multi-file changes.
- [ ] **AI-Guided Refactoring:** Commander Agent proposes architectural changes, Refactor Agent executes them.
