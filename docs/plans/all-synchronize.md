# All Synchronize Plan

## 🎯 Goal
Achieve a seamless, high-performance synchronization loop across the Zig (Engine), Elixir (Brain), and Svelte (Face) layers.

## 🔄 The Sync Loop

### 1. Zero-Copy Binary Pipeline (Native ➔ UI)
Standardize how binary data travels from native disk scans to the Svelte store.
- **Zig:** Packs binary slabs with `AetherProtocol`.
- **Elixir:** Passes raw binary frames over Phoenix Channels (Removing Base64).
- **Svelte:** Decodes binary slabs directly in the browser via `nif_decoder.ts`.

### 2. State-to-Disk Consistency (Watcher ➔ UI)
Ensure the UI perfectly reflects the file system in real-time.
- **Aether.Watcher:** Captures OS-level events.
- **Reconciliation:** Logic to merge incoming Delta events into the existing UI file tree without full re-scans.
- [ ] **Test:** Verify sub-10ms UI update on file save.

### 3. Cross-Layer Error Bus
Unified error reporting so a native crash is visible in the UI console.
- **Protocol:** Standardized JSON/Binary error envelope: `{source: "zig", code: :oom, message: "..."}`.
- **UI:** Global toast/notification system for native-layer alerts.

### 4. Agent-to-Agent Sync
Ensuring different GenServer agents (FileServer, Git, Lint) share a consistent view of the workspace.
- **PubSub:** Using Phoenix.PubSub for inter-agent broadcasts.
- **Registry:** Single source of truth for "Current Open File" state.

---

## 📅 Roadmap

- [ ] **Phase 1: Binary Standard** - Remove Base64 from EditorChannel and move to raw binary frames.
- [ ] **Phase 2: Delta Engine** - Implement smart merging in Svelte for `filetree:delta` events.
- [ ] **Phase 3: Unified Bus** - Connect Zig `error_tuple` to the Svelte alert system.
- [ ] **Phase 4: Structured Reality** - Integrate MessagePack for Agent↔UI data transport.

## ⚙️ Performance Targets
- **Init Sync:** <100ms for 10k files.
- **Delta Sync:** <5ms from disk-write to UI-update.
- **Memory Overhead:** <1MB additional RAM per 10k tracked elements.
