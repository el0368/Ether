# Aether Academy: AI Agents Strategy

## 🎯 Goal
Integrate Large Language Models (LLMs) to automate content creation for teachers and provide personalized guidance for students.

## 🤖 The 4 Specialized Academy Agents

### 1. Curriculum Designer AI (The "Architect")
- **Target:** Authors/Teachers.
- **Function:** 
  - Generates lesson outlines based on Grade and Subject.
  - Suggests prerequisites for new topics.
  - Ensures the curriculum follows standard educational frameworks (e.g., Common Core).
- **Tooling:** Uses `Jido` for workflow orchestration.

### 2. Exercise Generator AI (The "Creator")
- **Target:** Authors/Teachers.
- **Function:** 
  - Takes a "Theory" markdown file and automatically generates 5-10 multiple-choice or interactive exercises.
  - Generates "Distractors" (plausible but wrong answers) based on common student misconceptions.
- **Output:** Validated JSON in the [Content Schema](content_schema.md) format.

### 3. Personal Tutor AI (The "Guild")
- **Target:** Students.
- **Function:** 
  - Student-facing chat agent available during lessons.
  - Explains concepts in simpler terms if a student fails an exercise.
  - Not allowed to give the final answer, only hints and scaffolding.

### 4. Automated Assessor AI (The "Grader")
- **Target:** Students/Teachers.
- **Function:** 
  - Grades open-ended or "Free Text" responses.
  - Provides detailed feedback on *why* a response was partially correct or incorrect.
  - Identifies patterns of weakness for the `ProgressAgent`.

---

## 🛠️ Implementation Strategy
- **Local-First (P6):** Use Ollama/Llama-3 for local content generation to protect privacy and minimize costs.
- **Schema Enforcement:** Use `Instructor` (Elixir) to ensure AI output always matches our strict [Content Schema](content_schema.md).
- **Human-in-the-loop:** All AI-generated content must be "Approved" by a human author via the [Authoring Engine](authoring_engine.md) before publishing.

## 📅 Roadmap
- [ ] **Phase 1:** Exercise Generator prototype (Text-to-JSON).
- [ ] **Phase 2:** Integration of Tutor AI in the `StudentChannel`.
- [ ] **Phase 3:** Automated Assessor for complex, multi-step problems.
