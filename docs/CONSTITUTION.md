# Aether Project Constitution
**Stack:** Pure Elixir (SPEL-AI)
**Last Updated:** 2026-01-01

---

## 1. The Prime Directive: Pure Elixir Reflexes

- **NO NIFs**: Native Implemented Functions (Zig/Rust/C) are forbidden. The complexity cost of cross-compilation exceeds the performance benefit for this stage.
- **Concurrency First**: Replace raw speed with concurrency. Use `Task.async_stream`, `GenStage`, or `Flow` instead of dropping to C.
- **IO**: Use `File.stream!` and binary pattern matching for high-performance IO.

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
