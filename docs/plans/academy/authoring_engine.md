# Academy Authoring Engine (The Back-Stage)

## 🎨 Interface Goals
The "Back-Stage" uses the core Aether IDE infrastructure but switches "Code" terminology for "Content" terminology.

### Key Features
1.  **Topic Sidebar**: Browse curriculum by Grade/Subject instead of just raw files.
2.  **Visual Previewer**: A side-by-side view where you type JSON/Markdown on the left and see exactly what the Student sees on the right.
3.  **Grade Manager**: Drag-and-drop lessons to reorganize the learning path.

## ⚙️ Native Native Integration
- **Zig Scanner**: Scans all topics to create a "Curriculum Map."
- **Search**: Authors can find any lesson by keyword across the entire school system instantly.
- **Git State**: Teachers can "Branch" the curriculum to try out new teaching methods safely.

## 🛠️ To-Do
- [ ] Implement `CurriculumView.svelte` for the sidebar.
- [ ] Create `ExercisePreviewer.svelte` component.
- [ ] Add "Publish" button to commit changes to the students' live feed.
