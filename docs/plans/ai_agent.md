# AI Agent Roadmap

## 🤖 Core Strategy
- **Role:** Autonomous helpers that can modify code, run commands, and plan tasks.
- **Framework:** `Jido` (Action primitives) + `Instructor` (Structured LLM output).
- **Privacy:** Local-first where possible (Ollama), or secure API keys.

## 🧠 Planned Agents

### 1. Commander Agent ("The Manager")
- **Responsibility:** High-level task planning ("Refactor this module").
- **Tools:** Can delegate to other agents.
- **State:** Maintains conversational context and "Goal State".

### 2. Refactor Agent ("The Janitor")
- **Responsibility:** Safe code transformations.
- **Tools:** `Sourceror` (AST manipulation) for Elixir.
- **Actions:** `rename_function`, `move_module`, `extract_variable`.

### 3. Git Agent ("The Scribe")
- **Responsibility:** Version control management.
- **Actions:** `commit`, `push`, `branch`, `pr`.
- **Intelligence:** Auto-generates conventional commit messages based on diffs.

## 🚧 Status
- [ ] **Jido Integration:** Agents exist (e.g. `CommandAgent`) but need Jido Actions.
- [ ] **Context Window:** Implementing a "Code Context" vector store (pgvector).
- [ ] **Tooling:** Need standard `defaction` macros for all capabilities.
