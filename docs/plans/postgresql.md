# PostgreSQL Roadmap

## 🐘 Core Strategy
- **Role:** Persistent State for the IDE (not necessarily the user's project).
- **Isolation:** The IDE should work *mostly* without it (for quick edits), but needs it for advanced features.
- **Vectors:** Leveraging `pgvector` for AI memory.

## 🛑 Current Status
- **DISABLED:** Temporarily commented out in `application.ex` to fix startup issues.

## 🚧 Roadmap
- [ ] **Phase 1: Re-Activation**
  - Uncomment `Aether.Repo` in supervision tree.
  - Fix `mix ecto.migrate` in `start_dev.bat`.
  - Ensure graceful degradation if DB is missing (optional).

- [ ] **Phase 2: Project Metadata**
  - Store "Open Files", "Cursor Position", "Project Settings" in DB.
  - Implement `Aether.Context` context.

- [ ] **Phase 3: AI Memory (pgvector)**
  - Store Embedding Vectors for code chunks.
  - Semantic Search implementation.
