# Academy Templating & Rendering Strategy

## 🎯 Goal
Create a scalable architecture where a few master templates can render thousands of unique lessons, ensuring visual consistency and ultra-low maintenance.

## 🧱 The Template Hierarchy

### 1. Svelte Master Shells (`.svelte`)
These are the "Master Components" that define the layout of a lesson.
- **`LessonShell.svelte`**: The container for title, progress bar, navigation, and content area.
- **`QuizShell.svelte`**: A specialized shell for assessments with score tracking.
- **`SandboxShell.svelte`**: An interactive shell with an embedded code editor or virtual lab.

### 2. UI Atomic Blocks (Interactive Widgets)
Small, reusable components used inside the shells.
- **`RichText.svelte`**: Renders Markdown/HTML content.
- **`VideoPlayer.svelte`**: Optimized video streaming widget.
- **`MultiChoice.svelte`**: Data-driven question widget.
- **`CodeChallenge.svelte`**: Inline coding exercise widget.

### 3. Elixir HEEX Layouts (The SEO Wrapper)
Used for the high-level page structure that doesn't change frequently.
- **Navigation Bar**: Subject/Grade breadcrumbs.
- **Student Profile**: XP, Badges, and Avatar summary.
- **Footer**: Legal and Support links.

## 🔄 Data-Driven Rendering Flow

1.  **Request:** Student clicks on "Grade 5 Math > Fractions > Lesson 1".
2.  **Fetch:** `CurriculumAgent` (Elixir) retrieves `lesson_1.json` and `lesson_1.md`.
3.  **Inject:** The data is passed as "Props" to the **`LessonShell`**.
4.  **Render:** Svelte dynamically populates the template with the title, text, and interactive widgets defined in the data.

## 🚀 Benefits
- **Consistency:** Every lesson in the school follows the exact same design language.
- **Velocity:** Adding a new Type of lesson (e.g., "Virtual Field Trip") only requires building one new Shell.
- **Global Updates:** Changing the font or layout of 10,000 lessons happens in one file.

---

## 📅 Roadmap
- [ ] **Step 1:** Create the `LessonShell.svelte` mock in the Authoring Engine.
- [ ] **Step 2:** Define the JSON-to-Props mapping for the `MultipleChoice` widget.
- [ ] **Step 3:** Implement the "Live Preview" feature in the Back-Stage so authors see the template in real-time.
