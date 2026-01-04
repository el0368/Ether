# Progressive Priority Plan

## 🎯 Goal
Define a clear execution order for upcoming features, refactors, and stability updates to maintain a high-velocity development cycle.

## 🔥 P0: Critical Path (Essential for Milestone 1)
*Survival features and core stability.*
- [ ] **VS Code Theme Migration:** Transition from DaisyUI to VS Code Dark aesthetic.
- [ ] **Zero-Copy Finalization:** Base64 removal in Phoenix Channel frames.
- [ ] **Resilient Startup:** Final verification of `start_dev.bat` on clean environments.

## ⚡ P1: Experience & Polish (Milestone 1 Cleanup)
*Visual and interaction quality.*
- [ ] **File Icons:** Integration of Lucide icons for file types.
- [ ] **Directory Watcher Fix:** Resolve symlink/Windows nuances in `Aether.Watcher`.
- [ ] **Responsive Layout:** Ensure sidebar and editor handle resize smoothly.

## 🛠️ P2: Debt & Integrity (The "Ultimate Stability" Goal)
*Native layer hardening and refactoring.*
- [ ] **Zig defensive boundary:** Arg validation in `entry.c`.
- [ ] **Erlang Resources:** Persistent Zig state management.
- [ ] **Re-entrant Loops:** Yielding long scans back to the BEAM.

## 🚀 P3: Future Expansion (Milestone 2 & 3)
*New capabilities and intelligence.*
- [ ] **Text Editor:** Integration of Monaco or CodeMirror.
- [ ] **LSP Integration:** ElixirLS / Zig LSP server.
- [ ] **Vector Search:** Re-enabling PostgreSQL with `pgvector`.

---

## 📈 Planning Notes
- **Velocity Check:** Evaluate every Monday based on the Progress Log.
- **Pivot Rule:** If a P2 item becomes a P0 blocker (e.g., a crash), escalate immediately.
