# Elixir Academy: The Curriculum Brain

## 🎯 Goal
Orchestrate the educational logic, manage real-time student interaction, and ensure curriculum integrity using the power of the BEAM.

## 🧠 Academy Agents (Back-Stage)

### 1. `CurriculumAgent` (The Librarian)
- **Role:** Maintains a live, in-memory graph of the curriculum.
- **Function:** Tracks prerequisites (e.g., "Cannot do Lesson B without finishing Lesson A").
- **Persistence:** Syncs with the Zig scanner to stay updated with file changes.

### 2. `ValidationAgent` (The Quality Guard)
- **Role:** Automated "Linting" for educational content.
- **Function:** 
  - Ensures every quiz has a correct answer.
  - Checks for broken lesson links.
  - Validates that lesson difficulty matches the targeted Grade.

### 3. `AuthoringAgent` (The Studio Manager)
- **Role:** Manages the draft-to-publish workflow.
- **Function:** Handles file save/read operations specifically for lessons and exercises.

## ⚡ Classroom Services (Front-Stage)

### 1. `StudentChannel` (The Learning Bridge)
- **Real-time:** Pushes lesson content to students via Phoenix Channels.
- **Interactivity:** Receives exercise answers and provides instant feedback.

### 2. `ProgressAgent` (The Tracking Brain)
- **Role:** Real-time progress monitoring.
- **Function:** Collects "Exercise Solved" events and calculates real-time mastery scores.

## 📅 Roadmap

- [ ] **Phase 1: Basic Authoring** - Create agents to read/write the Academy JSON schema.
- [ ] **Phase 2: Live Feedback** - Implement the Channel logic for instant question grading.
- [ ] **Phase 3: Mastery Logic** - Add the GenServer state to track student progress during a session.

---

## ⚙️ Technical Edge
- **Massive Concurrency:** Handle 100,000+ simultaneous students with ease.
- **Fault Tolerance:** If a student's session crashes, a separate supervisor can restart their state instantly.
- **Hot-Patching:** Update the curriculum while students are actively learning, without downtime.
