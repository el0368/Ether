# Hybrid Isomorphic Migration Plan (Ether)

Refactor the "Ether" code editor from a "Server-Side Only" LiveView app to a **Hybrid Isomorphic App** using `live_svelte`.

## User Review Required

> [!IMPORTANT]
> This refactor introduces **Bun** as the primary asset builder, replacing the built-in `esbuild`. 
> We are also moving high-latency UI components (Editor, Sidebar) to **Svelte 5** with **Runes** for 0ms response.

## Proposed Changes

### [Plumbing] Asset Migration & Dependencies

#### [MODIFY] [mix.exs](file:///c:/GitHub/Ether/mix.exs)
- Add `{:live_svelte, "~> 0.15.0"}` to dependencies.
- Remove `{:esbuild, "~> 0.10", ...}` and `{:tailwind, "~> 0.3", ...}` if we move to Bun for both.
- Update aliases to use `bun` for setup and build.

#### [MODIFY] [config/config.exs](file:///c:/GitHub/Ether/config/config.exs) / [config/dev.exs](file:///c:/GitHub/Ether/config/dev.exs)
- Remove `:esbuild` and `:tailwind` configuration.
- Add `:live_svelte` configuration, pointing to `Bun` for bundling and SSR.

#### [NEW] [bun.config.js](file:///c:/GitHub/Ether/assets/bun.config.js)
- Configure Bun to bundle Svelte components, Monaco, and Tailwind.

---

### [Frontend] Svelte 5 Isomorphic Components

#### [NEW] [Editor.svelte](file:///c:/GitHub/Ether/assets/svelte/Editor.svelte)
- Port Monaco integration from `monaco.js` hook.
- Use `$props()` to receive `active_file` and `content`.
- Implement local typing state for 0ms response.

#### [NEW] [Workbench.svelte](file:///c:/GitHub/Ether/assets/svelte/Workbench.svelte)
- Orchestrate the main layout (Activity Bar, Sidebar, Editor).
- Coordinate state between components using Svelte 5 Runes.

#### [NEW] [Sidebar.svelte](file:///c:/GitHub/Ether/assets/svelte/Sidebar.svelte)
- Port Sidebar logic (Explorer, Search) to Svelte.

---

### [Backend] Data Bridge & Zig Integration

#### [MODIFY] [workbench_live.ex](file:///c:/GitHub/Ether/lib/ether_web/live/workbench_live.ex)
- Replace HEEx layout with a single `<.svelte name="Workbench" props={@svelte_props} />` call.
- Update `handle_info` to refresh Svelte props instead of updating streams.

#### [MODIFY] [scanner.ex](file:///c:/GitHub/Ether/lib/ether/scanner.ex)
- Ensure Zig NIF calls are wrapped in robust Tasks.
- Stream results to the LiveView which then pushes to Svelte.

## Verification Plan

### Automated Tests
- `mix test` to ensure backend logic still holds.
- Playwright E2E tests to verify 0ms typing response in Monaco.

### Manual Verification
- Verify that clicking sidebar icons is instant.
- Verify that opening a folder triggers the Zig scanner and updates the Svelte tree view.
- Verify that Tailwind classes in Svelte are correctly compiled.
