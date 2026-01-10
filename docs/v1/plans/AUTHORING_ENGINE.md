## 🎯 The North Star: The Dual-Purpose Engine
Ether is a high-performance, AI-native development environment designed for two simultaneous missions:

1.  **The Self-Hosting IDE:** A pro-grade replacement for Antigravity/VS Code. Ether must be powerful enough, stable enough, and "smart" enough to build its own codebase.
2.  **The Academy Back-Stage:** A specialized Content Studio for authoring world-class mathematics curriculum.

- [x] **The IDE:** Antigravity/VS Code for Curriculum Authors.
- [/] **The Content:** High-precision education modules stored in `docs/plans/academy/`.
- [ ] **The User:** Teachers, authors, and AI agents collaborating on educational growth.

---

## 🎭 The Architecture: Two Stages

### 1. The Back-Stage (Aether IDE)
*   **Role:** The Studio where content is born.
*   **Infrastructure:** [x] Zig (Fast binary scanning), [x] Elixir (Agent orchestration), [/] Svelte 5 (UI).
*   **Core Feature:** [ ] An AI-powered environment that treats "Lessons" and "Quizzes" with the same rigor that VS Code treats "Classes" and "Functions."

### 2. The Front-Stage (The Learning Portal)
*   **Role:** The beautiful, gamified interface where students consume the curriculum.
*   **Infrastructure:** [ ] Standard Web (Svelte 5) communicating with the Ether backend via Phoenix Channels.
*   **Core Feature:** [ ] Real-time feedback and progress tracking.

---

## 🛠️ Specialized "Back-Stage" Features

### 1. Curriculum Sidebar
- [ ] Instead of just files, authors see **Grade Levels**, **Subjects**, and **Topics**.
- [ ] Zig tracks the dependency graph (e.g., "Lesson B requires Lesson A").

### 2. Math-Native Authoring
- [ ] **LaTeX Rendering:** Real-time preview of mathematical formulas in the editor.
- [ ] **Interactive Preview:** Side-by-side view of the Svelte widget being configured.

### 3. AI Copilot for Teachers
- [ ] **Lesson Generation:** AI assists in creating 10 variations of a single math problem.
- [ ] **Validation:** Automatic checking of quiz logic (ensuring multiple-choice answers are solvable).

---

## 📅 Roadmap: From IDE to Studio

### Phase 1: Context Awareness
- [ ] **Academy Mapping:** Update the Zig scanner to recognize `academy/` folder metadata.
- [ ] **Content UI:** Implement the `CurriculumView` sidebar in Svelte.

### Phase 2: Authoring UX
- [ ] **Math Previewer:** Integrate KaTeX or MathJax into the Monaco editor.
- [ ] **Visual Builder:** Drag-and-drop reorganization of lesson sequences.

### Phase 3: The Intelligence
- [ ] **Curriculum Agent:** A Jido-based agent that can critique lesson clarity or generate missing topics.
- [ ] **Sync Engine:** High-speed delivery of authored content to the "Front-Stage" portal.

---
*Last Updated: 2026-01-09*
