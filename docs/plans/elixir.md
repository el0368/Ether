# Elixir Backend Roadmap

## 🧠 Core Principles
- **Orchestrator:** Elixir manages state, Zig does the heavy lifting.
- **Agentic:** Logic wrapped in GenServers (`FileServer`, `Scanner`, `LSP`).
- **Phoenix Channels:** The only communication pipe to Frontend.

## ✅ Completed
- [x] **Structure:** Agents defined in `lib/aether/agents/`.
- [x] **Scanner:** Hybrid integration with Zig NIF.
- [x] **Startup:** Resilient to zombie processes (Port 4000 killer).

## 🚧 In Progress
- [ ] **LSP Agent:** Fully integrate Language Server Protocol (ElixirLS).
- [ ] **Terminal:** Integrate `ExPty` or similar for real PTY support.
- [ ] **Database:** Re-enable PostgreSQL with proper migration handling.
- [ ] **Zero-Copy Receiver:** Refactor `Scanner.ex` to pass binary blobs directly.

## 🔮 Future
- [ ] **AI Commander:** Intelligent "Do X" agent using LLMs.
- [ ] **Multi-Node:** Cluster multiple Aether instances for remote dev.
