# Academy Content Schema

## 🌳 The Curriculum Tree
We represent the school as a folder structure, with different agents managing the metadata.

```text
/academy
  /subjects
    /math
      /grade-5
        /fractions
          - lesson_1.md      (Theory)
          - quiz_1.json      (Evaluation)
          - metadata.json    (Prerequisites, Scoring)
```

## 📝 Exercise Format (Sample JSON)
We use a standard JSON format that the Svelte Frontend can render into interactive widgets.

```json
{
  "id": "frac-basic-1",
  "type": "multiple-choice",
  "question": "What is 1/2 + 1/4?",
  "options": ["1/6", "2/6", "3/4", "1/4"],
  "answer": "3/4",
  "feedback": {
    "correct": "Excellent! You understand common denominators.",
    "incorrect": "Try finding a common denominator first."
  }
}
```

## 🤖 Content Agents
- **`ValidationAgent`**: Checks every `.json` file for "solve-ability" (e.g., ensures 1 answer exists).
- **`LibraryAgent`**: Generates the "Index" used by students to find lessons.
- **`AetherProtocol`**: Compact binary transmission of curricula to the student portal.
