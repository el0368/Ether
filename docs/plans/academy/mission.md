# Aether Academy: Mission & Vision

## 🎯 The Goal
To build a high-performance Content Engineering & Learning Platform. Use the speed of a native IDE (Back-Stage) to author world-class educational content delivered through a beautiful Student Portal (Front-Stage).

## 🎭 The Two Stages

### 1. The Back-Stage (Content Studio)
*   **Persona:** Authors, Teachers, Curriculum Designers.
*   **Interface:** VS Code-inspired Aether IDE.
*   **Function:** Creating exercises, organizing topics by grade, and tagging content with metadata.
*   **Native Power:** Use Zig/Elixir to manage millions of exercise files with zero lag.

### 2. The Front-Stage (Learning Portal)
*   **Persona:** Students.
*   **Interface:** High-aesthetics, gamified Svelte 5 application.
*   **Function:** Consuming lessons, solving interactive exercises, and tracking progress.
*   **Real-time:** Live feedback via Phoenix Channels.

## 🏗️ Technical Pillars
- **Local-First Authoring:** Content is stored as clean JSON/Markdown in Git (track every curriculum change).
- **Interactive Engine:** Svelte components that render dynamic math, code, or logic problems.
- **Zero-Trust Delivery:** Students only see "Published" content; the authoring logic is physically separate.

## 📅 Roadmap to Pivot

### 🏁 Phase 0: The Immediate Choice
Decide the starting point for Milestone 1:
- [ ] **Option A: Define Content First**: Finalize the JSON/Markdown schema for a "Standard Lesson" and "Interactive Quiz" in [Content Schema](content_schema.md).
- [ ] **Option B: Build the Shell First**: Prototype the master `LessonShell.svelte` component as defined in the [Templating Strategy](templating_strategy.md).

### 🚀 Long-term Phases
1.  **[ ] Part 1:** Finalize the [Content Schema](content_schema.md) (How questions look).
2.  **[ ] Part 2:** Build the [Authoring Engine](authoring_engine.md) (The Back-Stage UI).
3.  **[ ] Part 3:** Build the [Learning Portal](learning_portal.md) (The Front-Stage UI).
