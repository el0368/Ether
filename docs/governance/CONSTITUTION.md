# Aether Project Constitution
**Stack:** Pure Elixir (SPEL-AI)
**Last Updated:** 2026-01-01

---

## 1. The Unbreakable Zig Protocol
To ensure Zig is safe, stable, and requires zero manual setup, we follow these four "Unbreakable" laws.

1.  **Automated Binary Management (The Zero-Setup Law)**
    *   Never install Zig globally. Use `local_zig: true` in config.
    *   Run `mix zig.get` after `mix deps.get`.

2.  **Version Locking (The Stability Law)**
    *   Lock `zigler` to `~> 0.15.0`.

3.  **The "BEAM Citizen" Philosophy (The Safety Law)**
    *   **No `std.os.exit()`**: Never exit from Zig.
    *   **Use beam Allocator**: Always use `@import("beam").allocator`.
    *   **Avoid Infinite Loops**: Long running tasks must be Dirty Schedulers.

4.  **Reflex Isolation (The Structural Law)**
    *   **Pure Logic**: Elixir (The Brain).
    *   **Pure Speed**: Zig (The Reflexes).
    *   **The Bridge**: Use `~Z` sigil or `.zig` files.

---

## 2. Frontend Law: Svelte 5 Runes

- **Reactive Primitives**: All state logic must use `$state`, `$derived`, and `$effect`.
- **No Legacy**: `export let` and old store syntax are deprecated.
- **Communication**: Use Phoenix Channels via `EditorChannel` for all backend communication.

---

## 3. Intelligence Protocol: Instructor-First

- **Structured Outputs**: Never parse raw LLM JSON strings. Use `Instructor.chat_completion` with defined `Ecto` schemas.
- **Schema Driven**: Define the "Mind" of the agent in schemas (`ActionPlan`, `ThoughtTrace`).

---

## 4. Operational Simplification

- **One Runtime**: The project must run on a standard Erlang/Elixir install. No extra compilers required.
- **Standard Tools**: `mix` is the only build tool allowed.

---

## 5. Windows Compatibility

- **Launch Scripts**: Always use `.bat` files for Windows. Never rely on PowerShell script execution.
- **PATH Management**: Explicitly set PATH in scripts to include Elixir, Erlang, Git, Node.js.
- **NPM Watcher**: Use `cmd: ["/c", "npm", ...]` instead of `npm: [...]` in dev config.
